//
//  SignUpViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/8/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func CreateButton(_ sender: AnyObject) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if email != "" && password != "" {
            FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
                if error == nil {
                    FIREmailPasswordAuthProvider.credential(withEmail: email!, password: password!)
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            let alert = UIAlertController(title : "Error", message: "Invalid Email", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated:true, completion: nil)
                        case .errorCodeEmailAlreadyInUse:
                            let alert = UIAlertController(title : "Error", message: "Email Already Exists", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated:true, completion: nil)
                        case .errorCodeWeakPassword:
                            let alert = UIAlertController(title : "Error", message: "Password Too Weak", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated:true, completion: nil)
                        default:
                            let alert = UIAlertController(title : "Error", message: "Couldn't create account", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated:true, completion: nil)
                        }
                    }
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
    @IBAction func CancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
