//
//  ProfileTableViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/11/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    var dataScehma = Database()
    var userPosts = [UserPosts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserPosts()

        //self.tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return userPosts.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "userHeaderPostCell", for: indexPath) as! ProfileHeaderTableViewCell
            cell.selectionStyle = .none
            
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "userPostCell", for: indexPath) as! UserPostTableViewCell
            if indexPath.row <= userPosts.count {
                (cell as! UserPostTableViewCell).addressLabel.text = userPosts[indexPath.row-1].address
                (cell as! UserPostTableViewCell).ratingLabel.rating = userPosts[indexPath.row-1].rating
            }
        }
        
        // Configure the cell...
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    
    func getUserPosts(){
        userPosts.removeAll()
        _ = dataScehma.postsRef?.observe(FIRDataEventType.value, with: { (snapshot) in
            let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (_, value) in locationDict {
                if let data = value as? [String : AnyObject] {
                    print("here \(data)")
                    let user = data["User"] as! String
                    if user == FIRAuth.auth()?.currentUser?.email {
                        let post = UserPosts()
                        post.address = data["Address"] as! String
                        post.lat = data["Lat"] as! Double
                        post.long = data["Long"] as! Double
                        post.rating = data["Rating"] as! Int
                        post.review = data["Review"] as! String
                        self.userPosts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    

}
