//
//  AddPhotoViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/9/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit
import Photos

class AddPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var reviewTextField: UITextView!
    @IBOutlet weak var ratingView: RatingControl!
    @IBOutlet weak var imageToUpload: UIImageView!
    @IBOutlet weak var locationTextField: UITextField!
    
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    var userPost: UserPosts?
    let dataSchema = Database()
    
    var currentLocations = [Locations]()
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(databaseDoneNotification), name: NSNotification.Name(rawValue: databaseDoneNotificationKey), object: nil)
        
        reviewTextField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        reviewTextField.layer.borderWidth = 1.0
        reviewTextField.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func submitButton(_ sender: AnyObject) {
        if imageToUpload.image != nil && locationTextField.text != "" && ratingView.rating != 0 {
            if lat == nil || long == nil {
                lat = 0.0
                long = 0.0
            }
            let photo = Photo()
            photo.photo = imageToUpload.image!
            let user = FIRAuth.auth()?.currentUser
            userPost = UserPosts(user: (user?.email)!, lat: lat!, long: long!, address: locationTextField.text!, rating: ratingView.rating, review: reviewTextField.text)
            userPost?.photo = photo
            if let uploadPost = userPost {
                LoadingIndicatorView.show("Uploading Image")
                dataSchema.insertUserPost(post: uploadPost)
            }
        }
        else {
            let alert = UIAlertController(title : "Error", message: "Must enter all non optional fields!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated:true, completion: nil)
        }
    }
    
    @IBAction func selectPhotoButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func databaseDoneNotification() {
        print("omg got here")
        LoadingIndicatorView.hide()
        //currentLocations = dataSchema.locations
        self.performSegue(withIdentifier: "photoSubmit", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageToUpload.contentMode = .scaleAspectFit
            imageToUpload.image = pickedImage
            
            let imageUrl = info["UIImagePickerControllerReferenceURL"]
            let asset = PHAsset.fetchAssets(withALAssetURLs: [imageUrl as! URL], options: nil).firstObject! as PHAsset
            print("location: \(asset.location?.coordinate.latitude) \(asset.location?.coordinate.longitude)")
            if let latitude = asset.location?.coordinate.latitude {
                if let longitude = asset.location?.coordinate.longitude {
                    self.lat = latitude
                    self.long = longitude
                    getAddressForLatLng(latitude: latitude, longitude: longitude)
                }
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getAddressForLatLng(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error \(error?.localizedDescription)")
                return
            }
            if let places = placemarks {
                if places.count > 0 {
                    let pm = places[0] as CLPlacemark
                    print("address hopefully: \(pm.locality)")
                    print("name hopefully: \(pm.name)")
                    if let name = pm.name {
                        self.locationTextField.text = name
                    }
                }
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "photoSubmit"
        {
            //let destVC = segue.destination as? TabBarViewController
            /*if let newPost = userPost {
                newPost.printUserPost()
                destVC?.newUserPost = newPost
            }
            print("locations count \(currentLocations.count)")
            destVC?.locations = currentLocations*/
        }

    }
    

}
