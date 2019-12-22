//
//  PhotoCollectionViewContorller.swift
//  FlickrClient
//
//  Created by Tyts on 19.12.2019.
//  Copyright © 2019 Tyts&Co. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewContorller: UICollectionViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var navigation: UINavigationItem!
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    private let networkDataFetcher = NetworkDataFetcher(networkService: NetworkService(apiKey: "207453be27ace4aff3011edca54a6dde"))
    private let locationService = LocationService()
    private var searchResults: SearchResults?
    private var Photos: [Photo] = []
    var fetcherPage: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        if self.navigation.title == "Nearby" && locationService.setup() {
            locationService.startLocationManager()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if locationService.updatingLocation {
            locationService.stopLocationManager()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PhotoViewController
        destinationVC.photo = Photos[(sender as! PhotoCell).index]
    }

    // MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return Photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        cell.backgroundColor = UIColor.cyan
        let index: Int = indexPath.row
        cell.index = index
        cell.imageView.image = self.Photos[index].thumbnail
        
        if let sRes = self.searchResults {
            if self.Photos.count - 2 == indexPath.row && sRes.photos.pages > sRes.photos.page {
                self.loadImages(searchTerm: self.textField.text!, async: true, page: sRes.photos.page + 1)
            }
        }
        return cell
    }
    
}
// MARK: - UITextFieldDelegate
extension PhotoCollectionViewContorller : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.loadImages(searchTerm: textField.text!)
        
//        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoCollectionViewContorller: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {

    let paddingSpace = sectionInsets.left * 2
    let Width = view.frame.width - paddingSpace
    var Height = view.frame.width

    if let image = self.Photos[indexPath.row].thumbnail {
        let widthRatio = image.size.width / image.size.height
        Height = Width / widthRatio
    }

    return CGSize(width: Width, height: Height)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}

extension PhotoCollectionViewContorller {
    private func loadImages(searchTerm: String, async: Bool = false, page: Int? = nil) -> Void {
        let exec = { [weak self] in
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            self?.collectionView.addSubview(activityIndicator)
            if let center = self?.collectionView.center { activityIndicator.center = center }
            activityIndicator.translatesAutoresizingMaskIntoConstraints = true
            activityIndicator.startAnimating()

            self?.networkDataFetcher.fetchImages(searchTerm: searchTerm, latitude: self?.locationService.latitude, longitude: self?.locationService.longitude, page: page) { (sResults) in
                activityIndicator.removeFromSuperview()
                self?.searchResults = sResults
                if page == nil { self?.Photos.removeAll() }
                self?.searchResults?.photos.photo.forEach { flickrPhoto in
                    let photo = Photo(flickrPhoto: flickrPhoto)
                    let url = photo.url(size: Photo.thumbnailSize)
                    if let img = photo.loadImage(by: url) {
                        photo.thumbnail = img
                        self?.Photos.append(photo)
                    }
                }
                self?.collectionView?.reloadData()
            }
        }
        if async {
            DispatchQueue.main.async {
                exec()
            }
        } else {
            exec()
        }
    }
}
