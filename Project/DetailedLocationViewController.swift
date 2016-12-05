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
    let dataSchema = Database()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingDisplay: RatingDisplay!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func reviewButton(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = location.address
        distanceLabel.text = "\(location.distanceFromUser) miles"
        ratingDisplay.rating = location.rating
        getLocPhotos()

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
        var photoArray = [Photo]()
        let size = location.userPostKeys.count
        var count = 0
        for key in location.userPostKeys {
            dataSchema.postsRef?.child("User Post \(key)").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String : AnyObject] {
                    let photoURL = data["Photo"] as! String
                    //print("url \(photoURL)")
                    let getPhoto = Photo()
                    let url = NSURL(string: photoURL)  //userPhoto URL
                    let data2 = NSData(contentsOf: url! as URL)  //Convert into data
                    if data2 != nil  {
                        //print("getting photo yay")
                        getPhoto.photo = UIImage(data: data2! as Data)!
                        photoArray.append(getPhoto)
                    }

                }
                if count == size - 1{
                    self.location.photos = photoArray
                    self.collectionView.reloadData()
                }
                count += 1

            })
        }
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
