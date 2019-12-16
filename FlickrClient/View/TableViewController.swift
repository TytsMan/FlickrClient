//
//  ViewController.swift
//  FlickrClient
//
//  Created by Tyts on 15.12.2019.
//  Copyright © 2019 Tyts&Co. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBarItem!
    var segue: UIStoryboardSegue!
    
    
    private let networkDataFetcher = NetworkDataFetcher(networkService: NetworkService(apiKey: "207453be27ace4aff3011edca54a6dde"))
    private var searchResults: [Photo] = []
//    private let downloadService = DownloadService()
//    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.segue = segue
    }

// MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        let currentImage = searchResults[index].image
        let imageRatio = currentImage?.getImageRatio()
        let heigth = tableView.frame.width / (imageRatio ?? 1)
        
        return heigth

    }

// MARK: - Table Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoCell

        let photo = searchResults[indexPath.row]
        cell.configure(photo: photo)
        
        return cell
        
    }
    
      
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults.count
        
    }
 
    
}

//
// MARK: - Search Bar Delegate
//
extension TableViewController: UISearchBarDelegate {
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print("test", self.tabBar.tag)

        self.searchResults.removeAll()
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchBar.resignFirstResponder()

        networkDataFetcher.fetchImages(searchTerm: searchText) { [weak self] (searchResults) in

            if let searchResults = searchResults {
                searchResults.photos.photo.map { (flickrPhoto) in
                    self?.searchResults.append(Photo(flickrPhoto: flickrPhoto))
                }                
                self?.tableView.reloadData()
                self?.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }

    
}


extension UIImage {
    func getImageRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }
}
