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
    var searchLoc : CLLocationCoordinate2D?
    
    @IBOutlet weak var gpsButton: UIButton!
    @IBAction func gpsButtonPressed(_ sender: AnyObject) {
        
        if search{
            let region = MKCoordinateRegionMakeWithDistance(searchLoc!, 6000, 6000);
            self.mapView.setRegion(region, animated: true)
        }
        else {
            if let lat = userLoc?.coordinate.latitude {
                if let long = userLoc?.coordinate.longitude {
                    let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let region = MKCoordinateRegionMakeWithDistance(center, 6000, 6000);
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
    var search = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        gpsButton.backgroundColor = UIColor.white
        gpsButton.layer.cornerRadius = 0.5 * gpsButton.bounds.size.width
        gpsButton.clipsToBounds = true
        gpsButton.setImage(#imageLiteral(resourceName: "gpsIcon"), for: .normal)
        configureLocationManager()
        mapView.showsUserLocation = true
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
    
    func addAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        for loc in locations {
            let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(loc.lat, loc.long)
            let objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = pinLocation
            objectAnnotation.title = loc.address
            
            self.mapView.addAnnotation(objectAnnotation)
        }
        if !search {
            if let lat = userLoc?.coordinate.latitude {
                if let long = userLoc?.coordinate.longitude {
                    let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let region = MKCoordinateRegionMakeWithDistance(center, 6000, 6000);
                    self.mapView.setRegion(region, animated: true)
                }
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
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        if annotation.subtitle! == "Searched Location" {
            pinView?.pinTintColor = UIColor.blue
            pinView?.leftCalloutAccessoryView = nil
            pinView?.rightCalloutAccessoryView = nil
            pinView?.detailCalloutAccessoryView = nil

        }
        else {
            pinView?.pinTintColor = UIColor.red
        
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
        }
        
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
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if mapChangedFromUserInteraction == false {
            userLoc = locations.last
        }
    }
    
    func addSearchAnnotation(pinLocation: CLLocationCoordinate2D, title: String) {
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = title
        objectAnnotation.subtitle = "Searched Location"
    
        searchLoc = pinLocation
        
        self.mapView.addAnnotation(objectAnnotation)
        let region = MKCoordinateRegionMakeWithDistance(searchLoc!, 6000, 6000);
        self.mapView.setRegion(region, animated: true)

    }
    
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
