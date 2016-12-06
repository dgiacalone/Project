//
//  Database.swift
//  Project
//
//  Created by Delaney Giacalone on 11/20/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import FirebaseStorage

let databaseDoneNotificationKey = "com.dgiacalone.specialNotificationKey"

class Database {
    
    var root : FIRDatabaseReference?
    var locationsRef : FIRDatabaseReference?
    var postsRef : FIRDatabaseReference?
    var locations = [Locations]()
    var userPosts = [UserPosts]()
    let storage = FIRStorage.storage()    
    var storageRef : FIRStorageReference?
    var imagesRef: FIRStorageReference?
    var imageURL = ""
    var locPostsRef : FIRDatabaseReference?
    
    init() {
        self.root = FIRDatabase.database().reference()
        self.locationsRef = self.root?.child("Locations")
        self.postsRef = self.root?.child("User Posts")
        self.storageRef = self.storage.reference()
        //self.storageRef = storage.reference(forURL: "gs://project-aaf48.appspot.com")
        let imageName = NSUUID().uuidString
        self.imagesRef = storageRef?.child("Images").child("Image \(imageName)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSent), name: NSNotification.Name(rawValue: databaseDoneNotificationKey), object: nil)

    }
    
    @objc func notificationSent() {
        
    }

    
    func insertNewLocation(loc: Locations, postKey: String) {
        print("third(new location)")
        let key = (locationsRef?.childByAutoId().key)!
        let location: NSDictionary = ["Address" : loc.address,
                                      "Lat" : loc.lat,
                                      "Long" : loc.long,
                                      "Rating" : loc.rating as Double]
        let ref = locationsRef?.child("Location \(key)")
        ref?.setValue(location)
        
        self.locPostsRef = ref?.child("UserPosts")
        let posts: NSMutableDictionary = [:]
        posts.setValue("post", forKey: postKey)
        self.locPostsRef?.setValue(posts)
        
        print("third(new location) end")

        //NotificationCenter.default.post(name: Notification.Name(rawValue: databaseDoneNotificationKey), object: self)
        
    }
    
    func insertUserPost(post: UserPosts){
        print("first")
        let imageName = NSUUID().uuidString
        self.imagesRef = storageRef?.child("Images").child("Image \(imageName)")
        
        if let imageData = UIImagePNGRepresentation(post.photo.photo) {
            imagesRef?.put(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                }
                var key = ""
                if let image = metadata?.downloadURL()?.absoluteString {
                    key = (self.postsRef?.childByAutoId().key)!
                    print("unique key created: \(key)")
                    let userPost: NSDictionary = ["User" : post.user,
                                                  "Address" : post.address,
                                                  "Lat" : post.lat,
                                                  "Long" : post.long,
                                                  "Rating" : post.rating,
                                                  "Review": post.review,
                                                  "Photo": image]
                    let ref = self.postsRef?.child("User Post \(key)")
                    ref?.setValue(userPost)
                    self.imageURL = image
                    print("image \(self.imageURL)")
                }
                //print("done with user post")
                self.getLocations(post: post, postKey: key)
                print("first end")
            })
            
        }
    }
    
    func getLocations(post: UserPosts, postKey: String){
        print("second")
        //print("stating get locations")
        locations.removeAll()
        _ = locationsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
            var found = false
            for (key, value) in locationDict {
                if let data = value as? [String : AnyObject] {
                    //print("here \(data)")
                    let loc = Locations()
                    loc.address = data["Address"] as! String
                    loc.lat = data["Lat"] as! Double
                    loc.long = data["Long"] as! Double
                    loc.rating = data["Rating"] as! Double
                    self.locations.append(loc)
                    
                    let posts = data["UserPosts"] as! [String: String]
                    if loc.address == post.address {
                        //print("shouldn't be here")
                        print("getLocations key was found: \(postKey)")
                        self.updateLocation(post: post, postKey: postKey, locationsKey: key, posts: posts, oldRating: loc.rating)
                        found = true
                        break
                    }
                }
                
            }

            if found == false{
                print("get locations key was not found \(postKey)")
                let newLoc = Locations()
                newLoc.address = post.address
                newLoc.lat = post.lat
                newLoc.long = post.long
                newLoc.rating = Double(post.rating)
                newLoc.photos.append(post.photo)
                self.insertNewLocation(loc: newLoc, postKey: postKey)
            }
            print("second end")
            self.getUserPosts()
        })
    }

    func updateLocation(post: UserPosts, postKey: String, locationsKey: String, posts: [String:String], oldRating: Double) {
        print("third(update location)")

        var newPosts = posts
        newPosts.updateValue("post", forKey: postKey)
        print("size \(Double(posts.count - 1)) oldrating \(oldRating)")
        let sum = Double(posts.count - 1) * oldRating
        print("sum \(sum)")
        print("sum plus rating \(sum + Double(post.rating))")
        let newRating = (sum + Double(post.rating)) / Double(posts.count)
        print("newRating \(newRating)")
        locationsRef?.child(locationsKey).child("UserPosts").setValue(newPosts)
        locationsRef?.child(locationsKey).updateChildValues(["Rating": newRating])
        
        print("third(update location) end")

    }
    
    func getUserPosts(){
        _ = postsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
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
            NotificationCenter.default.post(name: Notification.Name(rawValue: databaseDoneNotificationKey), object: self)
        })
    }


}
