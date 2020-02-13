//
//  SettingsViewController.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 6.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    let customAlertView = CustomAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func logOutClicked(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
            
        }catch {
            self.customAlertView.alertUI(viewController: self, methodTitle: "Error", methodMessage: "Sign Out Error, Please Try Again")
            
        }
        
        
    }
    
}
