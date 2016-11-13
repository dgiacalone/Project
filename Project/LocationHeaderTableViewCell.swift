//
//  LocationHeaderTableViewCell.swift
//  Project
//
//  Created by Delaney Giacalone on 11/12/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class LocationHeaderTableViewCell: UITableViewCell {

    var currentDisplayType = "List"
    @IBOutlet weak var listMapControl: UISegmentedControl!
    @IBAction func listMapChanged(_ sender: AnyObject) {
        currentDisplayType = listMapControl.titleForSegment(at: listMapControl.selectedSegmentIndex)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
