//
//  MasterViewController.swift
//  iTunesDemo
//
//  Created by Apple on 5/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController,UISearchBarDelegate {
    
    //TODO for dowloading cellimageview for avoiding lazy loading
    let cache = NSCache<AnyObject, AnyObject>()

    var detailViewController: DetailViewController? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var objects = [Any]()
    var AppDetailArray = [Apps]()
    var filteredApps = [Apps]()
 


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "iTunes Music"

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
  
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        setupNetworkCall()
 
    }

    
    
    //MARK Calling network
    func setupNetworkCall(){
 
        //TODO coz of less time
        let url = URL(string:"https://itunes.apple.com/search?term=songs")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error)
            }
           
            do {
                let json : [String : Any] = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]
                let records:NSMutableArray = json["results"] as! NSArray as! NSMutableArray
                for item in records {
                    let AppObject = item as! [String:Any]
                    let  app = Apps()
                    app.artistName = (AppObject["artistName"] as? String)!
                    app.wrapperType = (AppObject["wrapperType"] as? String)!
                    app.kind = (AppObject["kind"] as? String)!
                    app.trackId = (AppObject["trackId"] as? Int)!
                    app.trackName = (AppObject["trackName"] as? String)!
                    app.artworkUrl = (AppObject["artworkUrl100"])! as! String
                    if( (AppObject["previewUrl"] as? String) == nil ){
                        app.previewUrl = "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/Music/v4/4e/44/b7/4e44b7dc-aaa2-c63b-fb38-88e1635b5b29/mzaf_1844128138535731917.plus.aac.p.m4a"
                        
                    } else{
                         app.previewUrl = (AppObject["previewUrl"] as? String)!
                    }
                    self.AppDetailArray.append(app)
                }
        
            } catch {
                print("error trying to convert data to JSON")
                print(error)
            }
        }.resume()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
             //   let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.appDetailObject = AppDetailArray[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredApps.count
        }
        return AppDetailArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        var appDetail = Apps()

        if isFiltering() {
             appDetail = filteredApps[indexPath.row]
            cell.textLabel!.text = appDetail.artistName
            cell.detailTextLabel?.text = appDetail.trackName
            
            return cell
        }
        else {
           appDetail = AppDetailArray[indexPath.row]
            cell.textLabel!.text = appDetail.artistName
            cell.detailTextLabel?.text = appDetail.trackName
            }
          return cell
        }

   

    //MARK : - Search Method
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredApps = AppDetailArray.filter { Apps in
                return (Apps.artistName?.lowercased().contains(searchText.lowercased()))!
            }
            
        } else {
            filteredApps = AppDetailArray
        }
        tableView.reloadData()

    }

}




