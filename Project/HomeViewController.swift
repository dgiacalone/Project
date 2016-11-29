//
//  HomeViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/14/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var listContainer: UIView!
    @IBOutlet weak var mapContainer: UIView!
    
    var listViewController : ListViewController?
    
    let dataSchema = Database()
    var locations = [Locations]()
    var newPost: UserPosts?
    var distances = [Double]()
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    let mileConversion = 1609.344
    
    @IBAction func displayTypeChanged(_ sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.listContainer.alpha = 1
                self.mapContainer.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.listContainer.alpha = 0
                self.mapContainer.alpha = 1
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listContainer.alpha = 1
        self.mapContainer.alpha = 0
        
        configureLocationManager()

        if let tbc = self.tabBarController as? TabBarViewController {
            newPost = tbc.newUserPost
            newPost?.photo.photoURL = dataSchema.imageURL
            newPost?.printUserPost()
        }
        getLocations()
        addNewPost()
        print("cool ")
        print(locations.count)
        
        // Do any additional setup after loading the view.
    }
    
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 100.0
            locationManager.startUpdatingLocation()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLocations(){
        _ = dataSchema.locationsRef?.observe(FIRDataEventType.value, with: { (snapshot) in
            var newLocations = [Locations]()
            let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (_, value) in locationDict {
                if let data = value as? [String : AnyObject] {
                    print("here \(data)")
                    let loc = Locations()
                    loc.address = data["Address"] as! String
                    loc.lat = data["Lat"] as! Double
                    loc.long = data["Long"] as! Double
                    loc.rating = data["Rating"] as! Int
                    loc.numPosts = data["NumPosts"] as! Int
                    newLocations.append(loc)
                }
            }
            self.locations = newLocations
            self.listViewController?.locations = newLocations
            self.getAllDistances()
            self.listViewController?.distances = self.distances
            self.listViewController?.updateTable()
        })
    }

    
    func addNewPost() {
        print("locations size \(locations.count)")
        if let post = newPost {
            var found = false
            /*for location in locations {
                print("okay: \(location.address) \(post.address)")
                if location.address == post.address {
                    let newRating = (location.rating + post.rating) / (location.photos.count + 1)
                    location.rating = newRating
                    location.photos.append(post.photo)
                    if newPost?.review != "" {
                        location.reviews.append(post.review)
                    }
                    found = true
                    print("found old location!")
                    break
                }
                location.printLocations()
            }*/
            if !found{
                let newLoc = Locations()
                newLoc.address = post.address
                newLoc.lat = post.lat
                newLoc.long = post.long
                newLoc.rating = post.rating
                newLoc.photos.append(post.photo)
                newLoc.numPosts = 1
                if post.review != "" {
                    newLoc.reviews.append(post.review)
                }
                locations.append(newLoc)
                dataSchema.insertLocation(loc: newLoc)
                //add to firebase
                print("locationssize: \(locations.count)")
                print("new location!")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location!.coordinate
        print("locations = \(userLocation?.latitude) \(userLocation?.longitude)")
    }

    func getDistance(lat: Double, long: Double) -> Double {
        var distanceInMiles = 0.0
        let coordinate = CLLocation(latitude: lat, longitude: long)
        if let userLoc = userLocation {
            let user = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
            let distanceInMeters = coordinate.distance(from: user)
            distanceInMiles = (distanceInMeters / mileConversion).roundTo(places:1)
        }
        return distanceInMiles
    }
    
    func getAllDistances() {
        print("locations count \(locations.count)")
        for loc in locations {
            let distance = getDistance(lat: loc.lat, long: loc.long)
            distances.append(distance)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "listContainer") {
            listViewController = segue.destination as? ListViewController
            listViewController?.locations = locations
            listViewController?.distances = distances

        }
        if (segue.identifier == "mapContainer") {
            let mapViewController = segue.destination as! MapViewController
            mapViewController.locations = locations
            
        }
    }
 
    
    @IBAction func unwindFromDetail(segue:UIStoryboardSegue) {
    
    }


}
