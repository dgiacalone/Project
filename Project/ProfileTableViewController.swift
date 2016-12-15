//
//  ProfileTableViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/11/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    var dataSchema = Database()
    var userPosts = [UserPosts]()
    var tbc: TabBarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        tableView.rowHeight = 100
        
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        settingsButton.addTarget(self, action: #selector(settings), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: settingsButton)
        navigationItem.rightBarButtonItem = item1

        DispatchQueue.main.async {
            LoadingIndicatorView.show("Loading Posts")
        }
        getUserPosts()
        
        tbc = self.tabBarController as! TabBarViewController?

        //self.tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func settings() {
        self.performSegue(withIdentifier: "settings", sender: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("removing observer post2")
        dataSchema.postsRef?.removeAllObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //LoadingIndicatorView.show("Loading Posts")
        //getUserPosts()
        self.userPosts = (tbc?.currentUserPosts)!
        self.tableView.reloadData()
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
        return userPosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "userPostCell", for: indexPath) as! UserPostTableViewCell
        if indexPath.row <= userPosts.count {
            (cell as! UserPostTableViewCell).addressLabel.text = userPosts[indexPath.row].address
            (cell as! UserPostTableViewCell).ratingLabel.rating = userPosts[indexPath.row].rating
            (cell as! UserPostTableViewCell).postImage.image = userPosts[indexPath.row].photo.photo
        }
        
        // Configure the cell...
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    
    func getUserPosts(){
        _ = dataSchema.postsRef?.observe(FIRDataEventType.value, with: { (snapshot) in
            self.userPosts.removeAll()
            let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (key, value) in locationDict {
                if let data = value as? [String : AnyObject] {
                    //print("here \(data)")
                    let user = data["User"] as! String
                    if user == FIRAuth.auth()?.currentUser?.email {
                        let post = UserPosts()
                        post.address = data["Address"] as! String
                        post.lat = data["Lat"] as! Double
                        post.long = data["Long"] as! Double
                        post.rating = data["Rating"] as! Int
                        post.review = data["Review"] as! String
                        post.key = key
                        
                        let photoURL = data["Photo"] as! String
                        //print("url \(photoURL)")
                        let getPhoto = Photo()
                        let url = NSURL(string: photoURL)  //userPhoto URL
                        let data2 = NSData(contentsOf: url! as URL)  //Convert into data
                        if data2 != nil  {
                            //print("getting photo yay")
                            getPhoto.photo = UIImage(data: data2! as Data)!
                            post.photo = getPhoto
                        }

                        self.userPosts.append(post)
                    }
                }
            }
            self.tbc?.currentUserPosts = self.userPosts
            LoadingIndicatorView.hide()
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
        if segue.identifier == "detailedPost" {
            let detailedViewController = segue.destination as! DetailedPostViewController
            detailedViewController.post = userPosts[(tableView.indexPathForSelectedRow?.row)!]
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func deletePost(segue:UIStoryboardSegue) {
    
    }
    
    

}
