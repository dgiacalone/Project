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
    var distance = 0.0
    var rating = 0
    var reviews = [String]()
    var photos = [Photo]()
    
    init() {
        
    }
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees,address: String, distance: Double, rating: Int) {
        self.lat = lat
        self.long = long
        self.address = address
        self.distance = distance
        self.rating = rating
    }

    
    
}
