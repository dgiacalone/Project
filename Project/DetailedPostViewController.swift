//
//  DetailedPostViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 12/2/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class DetailedPostViewController: UIViewController {

    var userPosts = [UserPosts]()
    var post = UserPosts()
    let dataSchema = Database()
    var tbc: TabBarViewController?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var userRating: RatingDisplay!
    @IBOutlet weak var reviewLabel: UILabel!
    
    @IBAction func deleteButton(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            //delete post and location key
            DispatchQueue.main.async {
                LoadingIndicatorView.show("Deleting Post")
            }
            self.deletePost()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = post.address
        imagePost.image = post.photo.photo
        userRating.rating = post.rating
        if post.review == "" {
            reviewLabel.text = "No Review"
        }
        else {
            reviewLabel.text = "Review: \(post.review)"
        }
        
        tbc = self.tabBarController as! TabBarViewController?

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deletePost() {
        self.dataSchema.postsRef?.child(self.post.key).removeValue()
        
        dataSchema.locationsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (key, value) in locationDict {
                if let data = value as? [String : AnyObject] {
                    if data["Address"] as? String == self.post.address {
                        let rating = data["Rating"] as? Double
                        let locKey = key
                        self.deletePostFromLoc(key: locKey, oldRating: rating!)
                        break
                    }
                }
            }
        })
        
    }
    
    func deletePostFromLoc(key: String, oldRating: Double) {
        let userPosts = self.dataSchema.locationsRef?.child(key).child("UserPosts")
        userPosts?.observeSingleEvent(of: .value, with: { (snapshot) in
            var count = 0
            if snapshot.childrenCount == 1 {
                self.dataSchema.locationsRef?.child(key).removeValue()
            }
            else {
                for item in snapshot.children.allObjects as! [FIRDataSnapshot]{
                    if item.key == (self.post.key).replacingOccurrences(of: "User Post ", with: "") {
                        item.ref.removeValue()
                    }
                    count += 1
                }
                let sum = (Double(count) * oldRating) - Double(self.post.rating)
                let newRating = sum / Double(count-1)
                self.dataSchema.locationsRef?.child(key).updateChildValues(["Rating": newRating])
            }
            self.getUserPosts()
        })
    }
    
    func getUserPosts(){
        _ = dataSchema.postsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            self.userPosts.removeAll()
            let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (key, value) in locationDict {
                if let data = value as? [String : AnyObject] {
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
                        let getPhoto = Photo()
                        let url = NSURL(string: photoURL)  //userPhoto URL
                        let data2 = NSData(contentsOf: url! as URL)  //Convert into data
                        if data2 != nil  {
                            getPhoto.photo = UIImage(data: data2! as Data)!
                            post.photo = getPhoto
                        }
                        self.userPosts.append(post)
                    }
                }
            }
            LoadingIndicatorView.hide()
            self.tbc?.didJustDelete = true
            self.tbc?.currentUserPosts = self.userPosts
            self.performSegue(withIdentifier: "deletePost", sender: nil)
        })
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
