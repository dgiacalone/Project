//
//  HomeViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/14/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit
import MapKit

let userLocationDone = "com.dgiacalone.specialNotificationKey2"

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var listContainer: UIView!
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    
    var distanceFilter = 50
    var ratingFilter = 1
    var itemsInFilterRange = false
    let defaults = UserDefaults.standard
    var isWithinFilter = false
    var tbc: TabBarViewController?
    
    var listViewController : ListViewController?
    var mapViewController : MapViewController?
    
    let dataSchema = Database()
    var locations = [Locations]()
    var locationsToDisplay = [Locations]()
    var newPost: UserPosts?
    var photosToDisplay = [String: Photo]()
    
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
        
        //NotificationCenter.default.addObserver(self, selector: #selector(gotUserLocation), name: NSNotification.Name(rawValue: userLocationDone), object: nil)
        print("load?")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSearch))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        self.listContainer.alpha = 1
        self.mapContainer.alpha = 0
        
        if let distance = defaults.string(forKey: "distance"){
            distanceFilter = Int(distance)!
        }
        if let rating = defaults.string(forKey: "rating"){
            ratingFilter = Int(rating)!
        }
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshPage))
        self.navigationItem.rightBarButtonItem = refreshButton

        
        configureLocationManager()
        tbc = self.tabBarController as! TabBarViewController?
  
        print("start")
        getStartingLocations()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //getStartingLocations()
        print("appear?")
        if (tbc?.didJustDelete)! == true{
            print("just deleted")
            tbc?.didJustDelete = false
            getStartingLocations()
        } else {
            self.locations = (tbc?.currentLocations)!
            self.locationsToDisplay = (tbc?.displayLocations)!
            self.listViewController?.updateTable()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("removing observer")
        dataSchema.locationsRef?.removeAllObservers()
    }
    
    func dismissSearch() {
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
    }
    
    func refreshPage() {
        getStartingLocations()
    }
    
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 100.0
            locationManager.startUpdatingLocation()
            
            print("locmanager \(locationManager.location)")
            if let latitude = locationManager.location?.coordinate.latitude {
                if let longitude = locationManager.location?.coordinate.longitude {
                    userLocation = CLLocationCoordinate2DMake(latitude, longitude)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location.coordinate
        }
        print("locmanager got here")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getDistance(lat: Double, long: Double) -> Double {
        var distanceInMiles = 0.0
        let coordinate = CLLocation(latitude: lat, longitude: long)
        //print("userlocation: \(userLocation)")
        if let userLoc = userLocation {
            //print("shouldn't be 0")
            let user = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
            let distanceInMeters = coordinate.distance(from: user)
            distanceInMiles = (distanceInMeters / mileConversion).roundTo(places:1)
        }
        return distanceInMiles
    }
    
    
    func getStartingLocations(){
        print("starting locations")
        //mapViewController?.mapChangedFromUserInteraction = false
        LoadingIndicatorView.show("Loading Locations")
        getStartingLocationsHelper()

    }
    
    func getStartingLocationsHelper() {
        _ = dataSchema.locationsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            //.observe(FIRDataEventType.value, with: { (snapshot) in
            //LoadingIndicatorView.show("Loading Locations")
            print("starting observer")
            self.locations.removeAll()
            self.locationsToDisplay.removeAll()
            //print("HOW MANY TIMES")
            var newItems: [Locations] = []
            let locationDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (key, value) in locationDict {
                if let data = value as? [String : AnyObject] {
                    //print("here \(data)")
                    let loc = Locations()
                    loc.key = key
                    loc.address = data["Address"] as! String
                    loc.lat = data["Lat"] as! Double
                    loc.long = data["Long"] as! Double
                    loc.rating = data["Rating"] as! Double
                    if let userData = data["UserPosts"] as? [String : AnyObject] {
                        var tempKeys = [String]()
                        for (k,_) in userData {
                            tempKeys.append(k)
                        }
                        loc.userPostKeys = tempKeys
                        /*if userData.count > 0 {
                         loc.userPostKey = userData.first?.value as! String
                         }*/
                    }
                    var distance = 0.0
                    if loc.lat == 0 && loc.long == 0 {
                        distance = -1
                    }
                    else {
                        distance = self.getDistance(lat: loc.lat, long: loc.long)
                    }
                    loc.distanceFromUser = distance
                    
                    newItems.append(loc)
                }
            }
            
            self.locations = newItems
            let inFilter = self.checkInFilter()
            if !inFilter {
                print("here")
                LoadingIndicatorView.hide()
            }
            else {
                self.getFirstPhotoURLs()
            }
            self.locationsToDisplay.sort(by: {
                return $0.distanceFromUser < $1.distanceFromUser
            })
            self.tbc?.currentLocations = self.locations
            self.tbc?.displayLocations = self.locationsToDisplay
            self.listViewController?.locations = self.locationsToDisplay
            self.mapViewController?.locations = self.locationsToDisplay
            //self.listViewController?.updateTable()
            
        })

    }
    
    func checkInFilter() -> Bool {
        var inFilter = false
        for loc in self.locations {
            if loc.distanceFromUser <= Double(self.distanceFilter) && Int(loc.rating) >= self.ratingFilter && loc.distanceFromUser >= 0 {
                inFilter = true
                self.locationsToDisplay.append(loc)
            }
        }
        return inFilter
    }
    
    func getFirstPhotoURLs(){
        let size = self.locationsToDisplay.count
        var count = 0
        for loc in self.locationsToDisplay {
            dataSchema.postsRef?.child("User Post \((loc.userPostKeys.first)!)").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String : AnyObject] {
                    if let photoURL = data["Photo"] as? String {
                        //print("photoURL home \(photoURL)")
                        let getPhoto = Photo()
                        let url = NSURL(string: photoURL)  //userPhoto URL
                        let data2 = NSData(contentsOf: url! as URL)  //Convert into data
                        if data2 != nil  {
                            getPhoto.photo = UIImage(data: data2! as Data)!
                        }
                        loc.photoToDisplay = getPhoto.photo
                        
                        //self.listViewController?.updateTable()
                    }
                }
                if count == size - 1{
                    print("hide")
                    LoadingIndicatorView.hide()
                    self.tbc?.currentLocations = self.locations
                    print("locatons count \(self.locations.count)")
                    self.tbc?.displayLocations = self.locationsToDisplay
                    self.listViewController?.locations = self.locationsToDisplay
                    self.mapViewController?.locations = self.locationsToDisplay
                    self.mapViewController?.addAnnotations()
                    self.listViewController?.updateTable()
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
        
        if segue.identifier == "listContainer" {
            listViewController = segue.destination as? ListViewController
            //print("count here \(locations.count)")
            listViewController?.locations = locations

        }
        if segue.identifier == "mapContainer" {
            mapViewController = segue.destination as? MapViewController
            mapViewController?.locations = locations
            mapViewController?.filterMiles = distanceFilter
            
        }
        if segue.identifier == "filter" {
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
        }
        else {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }
 
    
    @IBAction func cancelAddPhoto(segue:UIStoryboardSegue) {
    
    }
    
    @IBAction func submitAddPhoto(segue:UIStoryboardSegue) {
        getStartingLocations()
    }
    
    @IBAction func saveFilter(segue:UIStoryboardSegue) {
        if let sourceViewController = segue.source as? FilterViewController {
            distanceFilter = Int(sourceViewController.distanceRoundedVal)
            ratingFilter = Int(sourceViewController.ratingRoundedVal)
            getStartingLocations()
            //self.listViewController?.updateTable()
        }
    }


}
