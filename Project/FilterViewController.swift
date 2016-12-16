//
//  FilterViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 12/1/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    let distanceIncrement: Float = 5
    let ratingIncrement: Float = 1
    var distanceRoundedVal: Float = 50
    var ratingRoundedVal: Float = 1
    var sort = 0
    
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func segControlChanged(_ sender: Any) {
        sort = segControl.selectedSegmentIndex
    }
    @IBAction func distanceSliderChanged(_ sender: Any) {
        distanceRoundedVal = round(distanceSlider.value / distanceIncrement) * distanceIncrement
        distanceSlider.value = distanceRoundedVal
        distanceLabel.text = "\(Int(distanceRoundedVal)) miles"
    }
    @IBAction func ratingSliderChanged(_ sender: Any) {
        ratingRoundedVal = round(ratingSlider.value / ratingIncrement) * ratingIncrement
        ratingSlider.value = ratingRoundedVal
        if Int(ratingRoundedVal) == 1{
            ratingLabel.text = "\(Int(ratingRoundedVal)) star"
        }
        else {
            ratingLabel.text = "\(Int(ratingRoundedVal)) stars"
        }
    }
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    var savedDistance = 50
    var savedRating = 1
    var savedSort = 0
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let distance = defaults.string(forKey: "distance"){
            savedDistance = Int(distance)!
        }
        if let rating = defaults.string(forKey: "rating"){
            savedRating = Int(rating)!
        }
        if let sort = defaults.string(forKey: "sort") {
            savedSort = Int(sort)!
        }
        
        distanceSlider.setValue(Float(savedDistance), animated: false)
        ratingSlider.setValue(Float(savedRating), animated: false)
        distanceLabel.text = "\(savedDistance) miles"
        if savedRating == 1 {
            ratingLabel.text = "\(savedRating) star"
        }
        else {
            ratingLabel.text = "\(savedRating) stars"
        }
        segControl.selectedSegmentIndex = savedSort
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let button = sender as! UIButton
        if button === saveButton {
            distanceRoundedVal = round(distanceSlider.value / distanceIncrement) * distanceIncrement
            defaults.setValue(Int(distanceRoundedVal), forKey: "distance")
            ratingRoundedVal = round(ratingSlider.value / ratingIncrement) * ratingIncrement
            defaults.setValue(Int(ratingRoundedVal), forKey: "rating")
            sort = segControl.selectedSegmentIndex
            defaults.setValue(sort, forKey: "sort")
        }

        
    }
    

}
