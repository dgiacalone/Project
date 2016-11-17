//
//  Photo.swift
//  Project
//
//  Created by Delaney Giacalone on 11/13/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import Foundation

class Photo {
    
    var thumbsUp = 0
    var thumbsDown = 0
    var numReported = 0
    var photo = UIImage()
    
    init() {
        
    }
    
    init(thumbsUp: Int, thumbsDown: Int, numReported: Int, photo: UIImage) {
        self.thumbsUp = thumbsUp
        self.thumbsDown = thumbsDown
        self.numReported = numReported
        self.photo = photo
    }
    
}
