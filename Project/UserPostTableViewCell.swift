//
//  UserPostTableViewCell.swift
//  Project
//
//  Created by Delaney Giacalone on 11/11/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class UserPostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: RatingDisplay!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
