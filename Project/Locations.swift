//
//  Locations.swift
//  Project
//
//  Created by Delaney Giacalone on 11/12/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import Foundation

class Locations {
    
    var id = 0
    var location = ""
    var address = ""
    var distance = 0.0
    var rating = 0
    var reviews = [String]()
    var photos = [Photo]()
    
    init() {
        
    }
    
    init(id: Int, location: String, address: String, distance: Double, rating: Int) {
        self.id = id
        self.location = location
        self.address = address
        self.distance = distance
        self.rating = rating
    }

    
    
}
