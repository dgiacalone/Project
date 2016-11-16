//
//  UserPosts.swift
//  Project
//
//  Created by Delaney Giacalone on 11/13/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import Foundation

class UserPosts {
    
    var id = 0
    var user = ""
    var location = ""
    var address = ""
    var rating = 0
    var review = ""
    var photo = Photo()
    
    //photo?
    
    init() {
        
    }
    
    init(id: Int, user: String, location: String, address: String, rating: Int, review: String) {
        self.id = id
        self.user = user
        self.location = location
        self.address = address
        self.rating = rating
        self.review = review
    }

}
