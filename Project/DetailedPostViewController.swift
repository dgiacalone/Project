//
//  DetailedPostViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 12/2/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class DetailedPostViewController: UIViewController {

    var post = UserPosts()
    let dataSchema = Database()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var userRating: RatingDisplay!
    @IBOutlet weak var reviewLabel: UILabel!
    
    @IBAction func deleteButton(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            //delete post and location key
            LoadingIndicatorView.show("Deleting Post")
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
        
        if let tbc = self.tabBarController as? TabBarViewController {
            
        }
        

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
                        let locKey = key
                        //print("location key \(locKey)")
                        self.deletePostFromLoc(key: locKey)
                        break
                    }
                }
            }
        })
        
    }
    
    func deletePostFromLoc(key: String) {
        let userPosts = self.dataSchema.locationsRef?.child(key).child("UserPosts")
        userPosts?.observeSingleEvent(of: .value, with: { (snapshot) in
            //print("got inside deletePostFromLoc")
            //print(snapshot)
            if snapshot.childrenCount == 1 {
                self.dataSchema.locationsRef?.child(key).removeValue()
            }
            else {
                for item in snapshot.children.allObjects as! [FIRDataSnapshot]{
                    if item.value as? String == (self.post.key).replacingOccurrences(of: "User Post ", with: "") {
                        item.ref.removeValue()
                        break
                    }
                }
            }
            LoadingIndicatorView.hide()
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
