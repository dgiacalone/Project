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
        
        /*if let tbc = self.tabBarController as? TabBarViewController {
            newPost = tbc.newUserPost
            newPost?.photo.photoURL = dataSchema.imageURL
            newPost?.printUserPost()
            /*if let locs = tbc.locations {
                print("second time")
                locations = locs
                self.listViewController?.locations = locs
                getAllDistances()
                self.listViewController?.updateTable()
            }
            else {
                print("first time")
                dataSchema.getStartingLocations()
            }*/
        }*/

        self.listContainer.alpha = 1
        self.mapContainer.alpha = 0
        
        configureLocationManager()
        //dataSchema.getStartingLocations()
        getStartingLocations()

        //getLocations()
        //addNewPost()
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
            
            userLocation = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func getLocations(){
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
    }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location.coordinate
        }
        print("locations = \(userLocation?.latitude) \(userLocation?.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getDistance(lat: Double, long: Double) -> Double {
        var distanceInMiles = 0.0
        let coordinate = CLLocation(latitude: lat, longitude: long)
        print("userlocation: \(userLocation)")
        if let userLoc = userLocation {
            print("shouldn't be 0")
            let user = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
            let distanceInMeters = coordinate.distance(from: user)
            distanceInMiles = (distanceInMeters / mileConversion).roundTo(places:1)
        }
        return distanceInMiles
    }
    
    func getAllDistances() {
        print("distance locations count \(locations.count)")
        distances.removeAll()
        for loc in locations {
            var distance = 0.0
            if loc.lat == 0 && loc.long == 0 {
                distance = -1
            }
            else {
                distance = getDistance(lat: loc.lat, long: loc.long)
            }
            print("distancee: \(distance)")
            distances.append(distance)
        }
        self.listViewController?.distances = self.distances
        self.listViewController?.updateTable()
        
    }
    
    func getStartingLocations(){
        print("HOW MANY TIMES")
        //locations.removeAll()
        _ = dataSchema.locationsRef?.observe(FIRDataEventType.value, with: { (snapshot) in
            var newItems: [Locations] = []
            let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (_, value) in locationDict {
                if let data = value as? [String : AnyObject] {
                    print("here \(data)")
                    let loc = Locations()
                    loc.address = data["Address"] as! String
                    loc.lat = data["Lat"] as! Double
                    loc.long = data["Long"] as! Double
                    loc.rating = data["Rating"] as! Int
                    if let userData = data["UserPosts"] as? [String : AnyObject]{
                        //loop through and get photos and reviews
                        for (key, val) in userData {
                            
                        }
                    }
                    newItems.append(loc)
                }
            }
            self.locations = newItems
            self.listViewController?.locations = newItems
            self.getAllDistances()
            self.listViewController?.updateTable()
            print("size of locations2 \(self.locations.count)")
            //NotificationCenter.default.post(name: Notification.Name(rawValue: gotLocationsKey), object: self)
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "listContainer") {
            listViewController = segue.destination as? ListViewController
            //print
            print("count here \(locations.count)")
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
