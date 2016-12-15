//
//  SearchResultsTableViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 12/12/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

protocol LocateOnTheMap{
    func locateWithLongitude(lon:Double, andLatitude lat:Double, andTitle title: String)
    func noLocations()
}

class SearchResultsTableViewController: UITableViewController {

    var searchResults: [String]!
    var delegate: LocateOnTheMap!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchResult")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        // Configure the cell...

        return cell
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        self.dismiss(animated: true, completion: nil)
        let correctedAddress = self.searchResults[indexPath.row].addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        //let correctedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
        print("address \(correctedAddress!)")
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress!)&sensor=false"
        let searchURL : NSURL = NSURL(string: urlString as String)!
        print("url \(searchURL)")
        
        let task = URLSession.shared.dataTask(with: searchURL as URL) { (data, response, error) -> Void in
            do {
                if data != nil{
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  [String : AnyObject]
                    let status = dic["status"] as! String
                    if status == "ZERO_RESULTS" {
                        self.delegate.noLocations()
                    }
                    else {
                        let results = dic["results"] as! [AnyObject]
                        let first = results[0] as! [String: AnyObject]
                        let geo = first["geometry"] as! [String: AnyObject]
                        let loc = geo["location"] as! [String: AnyObject]
                        let lat = loc["lat"] as! Double
                        let long = loc["lng"] as! Double
                        
                        print("size \(self.searchResults.count)")
                        print("index \(indexPath.row)")
                        self.delegate.locateWithLongitude(lon: long, andLatitude: lat, andTitle: self.searchResults[indexPath.row] )
                    }
                }
            }catch {
                print("Error")
            }
        }
        task.resume()
    }
    
    func reloadDataWithArray(array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}