//
//  SettingsViewController.swift
//  Project
//
//  Created by Delaney Giacalone on 11/8/16.
//  Copyright © 2016 Delaney Giacalone. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBAction func signOutButton(_ sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
    }
    @IBAction func deleteAccountButton(_ sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            let user = FIRAuth.auth()?.currentUser
            user?.delete { error in
                if error != nil {
                    // An error happened.
                    print("Error: \(error)")
                    let alert = UIAlertController(title : "Error", message: "Couldn't delete account", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated:true, completion: nil)
                } else {
                    // Account deleted.
                }
            }
            self.performSegue(withIdentifier: "deleteAccount", sender: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
        
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
