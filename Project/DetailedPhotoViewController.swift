//
//  DetailedPhotoViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 12/9/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class DetailedPhotoViewController: UIViewController {

    var location = Locations()
    var photoToDisplay = Photo()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingDisplay: RatingDisplay!
    @IBOutlet weak var largerImage: UIImageView!
    @IBOutlet weak var reportButton: UIButton!
    
    @IBAction func reportClicked(_ sender: Any) {
        photoToDisplay.numReported+=1
        let alert = UIAlertController(title : "Report", message: "This photo has been reported", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = location.address
        if location.distanceFromUser < 0 {
            distanceLabel.text = "\(location.distanceFromSearchedLoc) miles"
        }
        else {
            distanceLabel.text = "\(location.distanceFromUser) miles"
        }
        ratingDisplay.rating = Int(location.rating)
        largerImage.image = photoToDisplay.photo
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
