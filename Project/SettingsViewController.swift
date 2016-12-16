//
//  SettingsViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/8/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    let dataSchema = Database()
    var userPosts = [UserPosts]()
    var user: FIRUser?
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBAction func signOutButton(_ sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
    }
    @IBAction func deleteAccountButton(_ sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.user?.delete { error in
                if error != nil {
                    // An error happened.
                    print("Error: \(error)")
                    let alert = UIAlertController(title : "Error", message: "Couldn't delete account", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated:true, completion: nil)
                } else {
                    // Account deleted.
                    self.deletePosts()
                }
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.user = FIRAuth.auth()?.currentUser
        accountLabel.text = "Account: \((self.user?.email)!)"
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.user = FIRAuth.auth()?.currentUser
        accountLabel.text = "Account: \((self.user?.email)!)"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deletePosts() {
        var postCount = 0
        if userPosts.count == 0 {
            self.performSegue(withIdentifier: "deleteAccount", sender: nil)
        }
        else {
            DispatchQueue.main.async {
                LoadingIndicatorView.show("Deleting Account")
            }
            for post in userPosts {
                self.dataSchema.postsRef?.child(post.key).removeValue()
                
                dataSchema.locationsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                    let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
                    for (key, value) in locationDict {
                        if let data = value as? [String : AnyObject] {
                            if data["Address"] as? String == post.address {
                                let rating = data["Rating"] as? Double
                                let locKey = key
                                self.deletePostFromLoc(key: locKey, oldRating: rating!, post: post, postCount: postCount, postSize: self.userPosts.count)
                            }
                        }
                    }
                    postCount += 1
                })
            }
        }

    }
    
    func deletePostFromLoc(key: String, oldRating: Double, post: UserPosts, postCount: Int, postSize: Int) {
        let userPosts = self.dataSchema.locationsRef?.child(key).child("UserPosts")
        userPosts?.observeSingleEvent(of: .value, with: { (snapshot) in
            var count = 0
            if snapshot.childrenCount == 1 {
                self.dataSchema.locationsRef?.child(key).removeValue()
            }
            else {
                for item in snapshot.children.allObjects as! [FIRDataSnapshot]{
                    if item.key == (post.key).replacingOccurrences(of: "User Post ", with: "") {
                        item.ref.removeValue()
                    }
                    count += 1
                }
                let sum = (Double(count) * oldRating) - Double(post.rating)
                let newRating = sum / Double(count-1)
                self.dataSchema.locationsRef?.child(key).updateChildValues(["Rating": newRating])
            }
            if postCount == postSize-1 {
                LoadingIndicatorView.hide()
                self.performSegue(withIdentifier: "deleteAccount", sender: nil)
            }
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
