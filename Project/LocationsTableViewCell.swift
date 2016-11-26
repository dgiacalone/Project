//
//  LocationsTableViewCell.swift
//  Project
//
//  Created by Delaney Giacalone on 11/12/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var exampleImage: UIImageView!
    @IBOutlet weak var ratingContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
