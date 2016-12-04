//
//  Locations.swift
//  Project
//
//  Created by Delaney Giacalone on 11/12/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import Foundation
import CoreLocation

class Locations {
    
    var lat = 0.0
    var long = 0.0
    var address = ""
    var rating = 0
    var reviews = [String]()
    var photos = [Photo]()
    var photoToDisplay = UIImage()
    var key = ""
    var distanceFromUser = -1.0
    var userPostKey = ""
    
    init() {
        
    }
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees,address: String, rating: Int) {
        self.lat = lat
        self.long = long
        self.address = address
        self.rating = rating
    }
    
    func printLocations() {
        print("lat: \(lat)\nlong: \(long)\naddress: \(address)\nrating: \(rating)")
    }

    
    
}
