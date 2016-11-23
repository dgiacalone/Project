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

class Database {
    
    var root : FIRDatabaseReference?
    var locationsRef : FIRDatabaseReference?
    var locations = [Locations]()
    
    init() {
        self.root = FIRDatabase.database().reference()
        self.locationsRef = self.root?.child("Locations")
    }
    
    func insertLocation(loc: Locations) {
        let key = (locationsRef?.childByAutoId().key)!
        let location: NSDictionary = ["Address" : loc.address,
                                      "Lat" : loc.lat,
                                      "Long" : loc.long,
                                      "Rating" : loc.rating]
        let locRef = locationsRef?.child("Location \(key)")
        locRef?.setValue(location)
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
