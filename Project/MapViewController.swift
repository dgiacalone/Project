//
//  MapViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/14/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var locations = [Locations]()
    var selectedLocation = Locations()
    var filterMiles = 50
    let mileToMeterConversion = 1609.34
    var mapChangedFromUserInteraction = false
    var userLoc : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        mapView.showsUserLocation = true
        //addAnnotations()
        mapView.delegate = self


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 100
            locationManager.startUpdatingLocation()
        }
    }
    
    /*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        let region2 = MKCoordinateRegionMakeWithDistance(center, 3000, 3000);


        self.mapView.setRegion(region2, animated: true)
    }*/
    
    func addAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        print("HERE \(locations.count)")
        
        for loc in locations {
            let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(loc.lat, loc.long)
            //let objectAnnotation = LocationAnnotation(coordinate: pinLocation)
            let objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = pinLocation
            objectAnnotation.title = loc.address
            //objectAnnotation.subtitle = "rating: \(Int(loc.rating))"
            //objectAnnotation.image = loc.photoToDisplay
            
            self.mapView.addAnnotation(objectAnnotation)
        }
        if let lat = userLoc?.coordinate.latitude {
            if let long = userLoc?.coordinate.longitude {
                let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let region2 = MKCoordinateRegionMakeWithDistance(center, 6000, 6000);
                self.mapView.setRegion(region2, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView || control == view.leftCalloutAccessoryView{
            for loc in locations {
                if loc.address == (view.annotation?.title)! {
                    selectedLocation = loc
                    self.performSegue(withIdentifier: "mapToDetailedLocation", sender: nil)
                    mapView.deselectAnnotation(view.annotation, animated: false)
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            //println("Pinview was nil")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        let arrowImage = UIImage(named: "arrowImage")
        let detailButton: UIButton = UIButton(type: .custom)
        detailButton.setImage(arrowImage, for: .normal)
        detailButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        pinView?.rightCalloutAccessoryView = detailButton
        
        for loc in locations {
            if loc.address == (annotation.title)! {
                selectedLocation = loc
            }
        }
        let exampleImage = selectedLocation.photoToDisplay
        let imageButton: UIButton = UIButton(type: .custom)
        imageButton.setImage(exampleImage, for: .normal)
        imageButton.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        pinView?.leftCalloutAccessoryView = imageButton
        
        let rating = RatingDisplay()
        rating.rating = Int(selectedLocation.rating)
        pinView!.detailCalloutAccessoryView = rating
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view:MKAnnotationView) {
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(calloutTapped(sender:)))
        view.addGestureRecognizer(tapGesture)
    }


    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.removeGestureRecognizer(view.gestureRecognizers!.first!)
    }

    func calloutTapped(sender:UITapGestureRecognizer) {
        let view = sender.view as! MKAnnotationView
        if let annotation = view.annotation as? MKPointAnnotation {
            for loc in locations {
                if loc.address == (view.annotation?.title)! {
                    selectedLocation = loc
                    self.performSegue(withIdentifier: "mapToDetailedLocation", sender: annotation)
                    mapView.deselectAnnotation(view.annotation, animated: false)
                }
            }
        }
    }
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view: UIView = self.mapView.subviews[0] as UIView
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if (mapChangedFromUserInteraction) {
            print("user changed map region")
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapChangedFromUserInteraction) {
            print("user changed map region")
        }
    }
    
    // This function is called each time the user moves.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if mapChangedFromUserInteraction == false {
            print("map here")
            userLoc = locations.last
            
            //let center = CLLocationCoordinate2D(latitude: userLoc!.coordinate.latitude, longitude: userLoc!.coordinate.longitude)
            //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            //let region2 = MKCoordinateRegionMakeWithDistance(center, 3000, 3000);
            
            //self.mapView.setRegion(region2, animated: true)
        }
    }
    
    /*func setUsersClosestCity()
    {
        for loc in locations {
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: loc.lat, longitude: loc.long)
            geoCoder.reverseGeocodeLocation(location)
            {
                (placemarks, error) -> Void in
                
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                // Address dictionary
                //print(placeMark.addressDictionary!)
                
                // Location name
                if let locationName = placeMark.addressDictionary?["Name"] as? NSString
                {
                    print("locName \(locationName)")
                }
                
                // Street address
                if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString
                {
                    print("street \(street)")
                }
                
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString
                {
                    print("city \(city)")
                }
                
                // Zip code
                if let zip = placeMark.addressDictionary?["ZIP"] as? NSString
                {
                    print("zip  \(zip)")
                }
                
                // Country
                if let country = placeMark.addressDictionary?["Country"] as? NSString
                {
                    print("country \(country)")
                }
            }
        }
    }*/

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "mapToDetailedLocation" {
            let detailedViewController = segue.destination as! DetailedLocationViewController
            detailedViewController.location = selectedLocation
            detailedViewController.locations = locations
        }
    }
    

}
