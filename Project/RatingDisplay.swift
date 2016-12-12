//
//  RatingDisplay.swift
//  Project
//
//  Created by Delaney Giacalone on 11/26/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class RatingDisplay: UIView {

    let numStars = 5
    let spacing = 10
    let size = 20
    var rating = 0 {
        didSet {
            updateRating()
            setNeedsLayout()
        }
    }
    let filledStarImage = UIImage(named: "filledStar")
    let emptyStarImage = UIImage(named: "emptyStar")
    var ratingButtons = [UIButton]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for i in 0..<numStars {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
            if i < rating {
                button.setImage(filledStarImage, for: .normal)
            }
            else {
                button.setImage(emptyStarImage, for: .normal)
            }
            button.isUserInteractionEnabled = false
            ratingButtons += [button]
            addSubview(button)
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        for i in 0..<numStars {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
            if i < rating {
                button.setImage(filledStarImage, for: .normal)
            }
            else {
                button.setImage(emptyStarImage, for: .normal)
            }
            button.isUserInteractionEnabled = false
            ratingButtons += [button]
            addSubview(button)
        }
    }
    
    func updateRating() {
        ratingButtons.removeAll()
        for i in 0..<numStars {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
            if i < rating {
                button.setImage(filledStarImage, for: .normal)
            }
            else {
                button.setImage(emptyStarImage, for: .normal)
            }
            button.isUserInteractionEnabled = false
            ratingButtons += [button]
            addSubview(button)
        }

    }
    
    override func layoutSubviews() {
        var buttonFrame = CGRect(x: 0, y: 0, width: size, height: size)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (10 + spacing))
            button.frame = buttonFrame
            button.isUserInteractionEnabled = false
        }
    }
    
    override var intrinsicContentSize: CGSize {
        //...
        let buttonSize = size
        let width = (buttonSize * numStars) + (spacing * (numStars - 1))
        
        return CGSize(width: width, height: buttonSize)
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
