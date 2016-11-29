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

class Database {
    
    var root : FIRDatabaseReference?
    var locationsRef : FIRDatabaseReference?
    var postsRef : FIRDatabaseReference?
    var locations = [Locations]()
    let storage = FIRStorage.storage()    
    var storageRef : FIRStorageReference?
    var imagesRef: FIRStorageReference?
    var imageURL = ""
    
    init() {
        self.root = FIRDatabase.database().reference()
        self.locationsRef = self.root?.child("Locations")
        self.postsRef = self.root?.child("User Posts")
        self.storageRef = self.storage.reference()
        //self.storageRef = storage.reference(forURL: "gs://project-aaf48.appspot.com")
        let imageName = NSUUID().uuidString
        self.imagesRef = storageRef?.child("Images").child("Image \(imageName)")
    }
    
    func insertLocation(loc: Locations) {
        let key = (locationsRef?.childByAutoId().key)!
        let location: NSDictionary = ["Address" : loc.address,
                                      "Lat" : loc.lat,
                                      "Long" : loc.long,
                                      "Rating" : loc.rating,
                                      "NumPosts" : loc.numPosts]
        let ref = locationsRef?.child("Location \(key)")
        ref?.setValue(location)
        
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
                    print(error)
                }
                if let image = metadata?.downloadURL()?.absoluteString {
                    let key = (self.postsRef?.childByAutoId().key)!
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
            })
            
        }
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
