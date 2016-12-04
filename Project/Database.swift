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
        let key = (locationsRef?.childByAutoId().key)!
        let location: NSDictionary = ["Address" : loc.address,
                                      "Lat" : loc.lat,
                                      "Long" : loc.long,
                                      "Rating" : loc.rating]
        let ref = locationsRef?.child("Location \(key)")
        ref?.setValue(location)
        
        self.locPostsRef = ref?.child("UserPosts")
        let posts: NSMutableDictionary = [:]
        posts.setValue(postKey, forKey: "UserPost 0")
        self.locPostsRef?.setValue(posts)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: databaseDoneNotificationKey), object: self)
        
        /*self.reviewsRef = ref?.child("Reviews")
        let reviews: NSMutableDictionary = [:]
        print("count \(loc.reviews.count)")
        if loc.reviews.count > 0 {
            for i in 0...loc.reviews.count-1 {
                print("review \(loc.reviews[i])")
                reviews.setValue(loc.reviews[i], forKey: "Review \(i)")
            }
            reviewsRef?.setValue(reviews)
        }
        
        self.photosRef = ref?.child("Photos")
        let photos: NSMutableDictionary = [:]
        for i in 0...loc.photos.count-1 {
            photos.setValue(loc.photos[i].photoURL, forKey: "Photo \(i)")
        }
        photosRef?.setValue(photos)*/
    }
    
    func insertUserPost(post: UserPosts){
        if let imageData = UIImagePNGRepresentation(post.photo.photo) {
            imagesRef?.put(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                }
                var key = ""
                if let image = metadata?.downloadURL()?.absoluteString {
                    key = (self.postsRef?.childByAutoId().key)!
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
                }
                //print("done with user post")
                self.getLocations(post: post, postKey: key)
            })
            
        }
    }
    
    func getLocations(post: UserPosts, postKey: String){
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
                    loc.rating = data["Rating"] as! Int
                    self.locations.append(loc)
                    
                    if loc.address == post.address {
                        self.updateLocation(post: post, postKey: postKey, locationsKey: key, posts: data["UserPosts"] as! NSMutableDictionary, oldRating: loc.rating)
                        found = true
                    }
                }
                
            }
            //print("size of locations \(self.locations.count)")
            //print("done with get locations \(self.locations.count)")
            if found == false{
                let newLoc = Locations()
                newLoc.address = post.address
                newLoc.lat = post.lat
                newLoc.long = post.long
                newLoc.rating = post.rating
                newLoc.photos.append(post.photo)
                self.insertNewLocation(loc: newLoc, postKey: postKey)
            }
        })
    }

    func updateLocation(post: UserPosts, postKey: String, locationsKey: String, posts: NSMutableDictionary, oldRating: Int) {
        
        posts["UserPost \(posts.count)"] = postKey
        //posts.setValue(postKey, forKey: "UserPost \(posts.count)")
        //print("post count \(posts.count) posts \(posts)")
        //need to get all ratings
        let sum = (posts.count - 1) * oldRating
        let newRating = (sum + post.rating) / posts.count
        locationsRef?.child(locationsKey).child("UserPosts").setValue(posts)
        locationsRef?.child(locationsKey).updateChildValues(["Rating": newRating])
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: databaseDoneNotificationKey), object: self)
    }
    
    /*func changeLocation(loc: Locations){
        let key = root.child("Locations").childByAutoId().key
        let post = ["uid": userID,
                    "author": username,
                    "title": title,
                    "body": body]
        let childUpdates = ["/posts/\(key)": post,
                            "/user-posts/\(userID)/\(key)/": post]
        root.updateChildValues(childUpdates)
    }*/
    
    

}
