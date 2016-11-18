//
//  UserPosts.swift
//  Project
//
//  Created by Delaney Giacalone on 11/13/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import Foundation
import CoreLocation

class UserPosts {
    
    var user = ""
    var lat = 0.0
    var long = 0.0
    var address = ""
    var rating = 0
    var review = ""
    var photo = Photo()
    
    //photo?
    
    init() {
        
    }
    
    init(user: String, lat: CLLocationDegrees, long: CLLocationDegrees, address: String, rating: Int, review: String) {
        self.user = user
        self.lat = lat
        self.long = long
        self.address = address
        self.rating = rating
        self.review = review
    }
    
    func printUserPost() {
        print("user: \(self.user)\nlat: \(lat)\nlong: \(long)\naddress: \(address)\nrating: \(rating)\nreview: \(review)")
    }

}
