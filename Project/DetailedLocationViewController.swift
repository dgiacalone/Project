//
//  DetailedLocationViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 12/4/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class DetailedLocationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var location = Locations()
    var locations = [Locations]()
    let dataSchema = Database()
    var tbc: TabBarViewController?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingDisplay: RatingDisplay!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func reviewButton(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbc = self.tabBarController as! TabBarViewController?
        nameLabel.text = location.address
        if location.distanceFromUser < 0 {
            distanceLabel.text = "\(location.distanceFromSearchedLoc) miles"
        }
        else {
            distanceLabel.text = "\(location.distanceFromUser) miles"
        }
        ratingDisplay.rating = Int(location.rating)
        if location.userPostKeys.count != location.photos.count {
            getLocPhotos()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return location.userPostKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationPhoto", for: indexPath) as! LocationCollectionViewCell
        if location.photos.count > indexPath.row{
            cell.imageInCell.image = location.photos[indexPath.row].photo
        }
        //cell.backgroundColor = UIColor.black
        
        // Configure the cell
        
        return cell
    }
            
    func getLocPhotos() {
        LoadingIndicatorView.show("Loading Photos")
        var photoArray = [Photo]()
        var reviewArray = [String]()
        let size = location.userPostKeys.count
        var count = 0
        for key in location.userPostKeys {
            dataSchema.postsRef?.child("User Post \(key)").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String : AnyObject] {
                    let photoURL = data["Photo"] as! String
                    let review = data["Review"] as! String
                    //print("url \(photoURL)")
                    let getPhoto = Photo()
                    let url = NSURL(string: photoURL)  //userPhoto URL
                    let data2 = NSData(contentsOf: url! as URL)  //Convert into data
                    if data2 != nil  {
                        //print("getting photo yay")
                        getPhoto.photo = UIImage(data: data2! as Data)!
                        photoArray.append(getPhoto)
                    }
                    if review != "" {
                        reviewArray.append(review)
                    }

                }
                if count == size - 1{
                    self.tbc?.currentLocations = self.locations
                    self.location.photos = photoArray
                    self.location.reviews = reviewArray
                    LoadingIndicatorView.hide()
                    self.collectionView.reloadData()
                }
                count += 1

            })
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "reviews" {
            let reviewsTableViewController = segue.destination as! ReviewsTableViewController
            reviewsTableViewController.reviews = location.reviews
        }
        if segue.identifier == "detailedPhoto" {
            let detailedPhotoViewController = segue.destination as! DetailedPhotoViewController
            detailedPhotoViewController.location = location
            let indexPath = collectionView.indexPath(for: sender as! LocationCollectionViewCell)
            detailedPhotoViewController.photoToDisplay = location.photos[indexPath!.row]
        }
    }
    

}
