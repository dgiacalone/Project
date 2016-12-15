//
//  AddPhotoViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/9/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit
import Photos

class AddPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var reviewTextField: UITextView!
    @IBOutlet weak var ratingView: RatingControl!
    @IBOutlet weak var imageToUpload: UIImageView!
    @IBOutlet weak var locationTextField: UITextField!
    
    var lat: CLLocationDegrees?
    var long: CLLocationDegrees?
    var userPost: UserPosts?
    let dataSchema = Database()
    var tbc: TabBarViewController?
    
    var currentLocations = [Locations]()
    var userPosts = [UserPosts]()
    
    var activeField = UITextField()
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(databaseDoneNotification), name: NSNotification.Name(rawValue: databaseDoneNotificationKey), object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        reviewTextField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        reviewTextField.layer.borderWidth = 1.0
        reviewTextField.layer.cornerRadius = 5
        
        reviewTextField.delegate = self
        locationTextField.delegate = self
        
        tbc = self.tabBarController as! TabBarViewController?
        currentLocations = (tbc?.currentLocations)!
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        reviewTextField.text = ""
        locationTextField.text = ""
        ratingView.rating = 0
        imageToUpload.image = nil
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
                DispatchQueue.main.async {
                    LoadingIndicatorView.show("Uploading Image")
                }
                dataSchema.insertUserPost(post: uploadPost, locs: currentLocations)
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
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
        
        //scroll up when keyboard is up
    }
    
    func databaseDoneNotification() {
        LoadingIndicatorView.hide()
        //self.tbc?.currentLocations = dataSchema.locations
        self.tbc?.currentUserPosts = dataSchema.userPosts
        //currentLocations = dataSchema.locations
        print("segue")
        reviewTextField.text = ""
        locationTextField.text = ""
        ratingView.rating = 0
        imageToUpload.image = nil
        self.performSegue(withIdentifier: "photoSubmit", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageToUpload.contentMode = .scaleAspectFit
            imageToUpload.image = pickedImage
            
            let imageUrl = info["UIImagePickerControllerReferenceURL"]
            let asset = PHAsset.fetchAssets(withALAssetURLs: [imageUrl as! URL], options: nil).firstObject! as PHAsset
            //print("location: \(asset.location?.coordinate.latitude) \(asset.location?.coordinate.longitude)")
            if let latitude = asset.location?.coordinate.latitude {
                if let longitude = asset.location?.coordinate.longitude {
                    self.lat = latitude
                    self.long = longitude
                    getAddressForLatLong(latitude: latitude, longitude: longitude)
                }
            }
            else {
                self.locationTextField.text = ""
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getAddressForLatLong(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error \(error?.localizedDescription)")
                return
            }
            if let places = placemarks {
                if places.count > 0 {
                    let pm = places[0] as CLPlacemark
                    //print("address hopefully: \(pm.locality)")
                    //print("name hopefully: \(pm.name)")
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
    
    /*func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }*/
    
    /*func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 100)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }*/
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "photoSubmit"
        {

        }

    }
    

}
