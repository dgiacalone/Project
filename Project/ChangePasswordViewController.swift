//
//  ChangePasswordViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/12/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {    
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func submitButton(_ sender: AnyObject) {
        let email = emailTextField.text
        let oldPassword = oldPasswordTextField.text
        let newPassword = newPasswordTextField.text
        let confirmPassword = confirmPasswordTextField.text
        
        if oldPassword != "" && newPassword != "" && confirmPassword != "" && email != "" {
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: email!, password: oldPassword!)
            let user = FIRAuth.auth()?.currentUser
            
            user?.reauthenticate(with: credential) { error in
                if error == nil {
                    // User re-authenticated.
                    user?.updatePassword(newPassword!) { error in
                        if newPassword == confirmPassword {
                            if error == nil {
                                // Password updated.
                                self.dismiss(animated: true, completion: nil)
                            }
                            else {
                                print("Error: \(error)")
                                let alert = UIAlertController(title : "Error", message: "Couldn't change password", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated:true, completion: nil)
                            }
                        }
                        else {
                            let alert = UIAlertController(title : "Error", message: "Password's must match", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated:true, completion: nil)
                        }
                    }
                }
                else {
                    print("Error: \(error)")
                    let alert = UIAlertController(title : "Error", message: "Couldn't change password", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated:true, completion: nil)
                }
            }
        }
        else {
            // An error happened.
            let alert = UIAlertController(title : "Error", message: "Must enter all fields", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated:true, completion: nil)
        }
    }
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
