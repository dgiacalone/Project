//
//  Locations.swift
//  Project
//
//  Created by Delaney Giacalone on 11/12/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import Foundation

class Locations {
    
    var location = ""
    var address = ""
    var distance = 0.0
    var rating = 0
    
    init() {
        
    }
    
    init(location: String, address: String, distance: Double, rating: Int) {
        self.location = location
        self.address = address
        self.distance = distance
        self.rating = rating
    }

    
    
}
