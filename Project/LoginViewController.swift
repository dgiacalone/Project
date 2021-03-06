//
//  LoginViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/8/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    @IBAction func LoginButton(_ sender: AnyObject) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if email != "" && password != "" {
            FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "loggedIn", sender: self)
                }
                else {
                    let alert = UIAlertController(title : "Error", message: "Incorrect email or password", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated:true, completion: nil)
                }
            })
        }
        else {
            let alert = UIAlertController(title : "Error", message: "Enter email and password!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated:true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "loggedIn" {
            let destination = segue.destination as! TabBarViewController
            destination.currentLocations.removeAll()
            destination.currentUserPosts.removeAll()
            destination.displayLocations.removeAll()
        }
    }
    

}
