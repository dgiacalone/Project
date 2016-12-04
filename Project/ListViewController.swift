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
    //var distances = [Double]()
    
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
        //print("okay size \(locations.count) \(indexPath.row)")
        cell?.addressLabel.text = locations[indexPath.row].address
        cell?.ratingContainer.rating = locations[indexPath.row].rating
        if locations[indexPath.row].distanceFromUser == -1 {
            cell?.distanceLabel.text = "Unknown"
        }
        else if locations[indexPath.row].distanceFromUser > 50{
            cell?.distanceLabel.text = "50+ miles"
        }
        else {
            cell?.distanceLabel.text = "\(locations[indexPath.row].distanceFromUser) miles"
        }
        cell?.exampleImage.image = locations[indexPath.row].photoToDisplay
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
         return 100
    }
    
    func updateTable() {
        self.tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
