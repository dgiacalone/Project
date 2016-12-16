//
//  ListViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/14/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var locations = [Locations]()
    var search = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationsCell", for: indexPath) as? LocationsTableViewCell
        if locations.count > indexPath.row {
            cell?.addressLabel.text = locations[indexPath.row].address
            cell?.ratingContainer.rating = Int(locations[indexPath.row].rating)
            if search {
                if locations[indexPath.row].distanceFromSearchedLoc == -1 {
                    cell?.distanceLabel.text = "Unknown"
                }
                else if locations[indexPath.row].distanceFromSearchedLoc > 50{
                    cell?.distanceLabel.text = "50+ miles"
                }
                else {
                    cell?.distanceLabel.text = "\(locations[indexPath.row].distanceFromSearchedLoc) miles"
                }
            }
            else {
                if locations[indexPath.row].distanceFromUser == -1 {
                    cell?.distanceLabel.text = "Unknown"
                }
                else if locations[indexPath.row].distanceFromUser > 50{
                    cell?.distanceLabel.text = "50+ miles"
                }
                else {
                    cell?.distanceLabel.text = "\(locations[indexPath.row].distanceFromUser) miles"
                }
            }
            cell?.exampleImage.image = locations[indexPath.row].photoToDisplay
        }
        return cell!
    }
    
    func updateTable() {
        self.tableView.reloadData()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "locationDetail" {
            let detailedViewController = segue.destination as! DetailedLocationViewController
            detailedViewController.location = locations[(tableView.indexPathForSelectedRow?.row)!]
            detailedViewController.locations = locations
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    

}
