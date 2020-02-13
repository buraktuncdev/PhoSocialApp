//
//  ViewController.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 5.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import UIKit
import Firebase
import Network

class LoginViewController: UIViewController {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let customTextFieldDelegate = CustomTextFieldDelegate()
    let  customAlertView = CustomAlertView()
    let monitor = NWPathMonitor()
    
    // Unsubscribe From Keyboard Notifications While View is Disappearing
      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          unsubscribeFromKeyboardNotifications()
      }
      
      
      // Subscribe To Keyboard Notifications While View is Appearing after the click Return
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          subscribeToKeyboardShowNotifications()
          
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = .green
        view.addSubview(self.activityIndicator)
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                debugPrint("Internet connection is on.")
            } else {
                performUIUpdatesOnMain {
                    self.customAlertView.alertUI(viewController: self, methodTitle: "Internet Error", methodMessage: "There's no internet connection. Please Check")
                }
            }
        }
        
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        monitor.start(queue: queue)
        // Do any additional setup after loading the view.
        emailTextField.delegate = customTextFieldDelegate
        passwordTextField.delegate = customTextFieldDelegate
    }
    
    // MARK: Login with Firebase Email-Password Authentication
    
    @IBAction func loginClicked(_ sender: Any) {
        
        activityIndicator.startAnimating()
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {(authData, error) in
                if error != nil {
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.customAlertView.alertUI(viewController: self, methodTitle: "Error", methodMessage: error?.localizedDescription ?? "Firebase Login Error")
                    }
                    
                }else{
                    performUIUpdatesOnMain {
                        
                        self.activityIndicator.stopAnimating()
                        self.performSegue(withIdentifier: "toTabbarSegueIdentifier", sender: nil)
                    }
                }
            })
        } else {
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.customAlertView.alertUI(viewController: self, methodTitle: "Error", methodMessage: "Username/Password is empty")
            }
        }
    }
    
    // MARK: SignUp with Firebase Email-Password Authentication
    
    @IBAction func signUpClicked(_ sender: Any) {
         self.activityIndicator.startAnimating()
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {(authdata,error) in
                if error != nil {
                    performUIUpdatesOnMain {
                         self.activityIndicator.stopAnimating()
                        self.customAlertView.alertUI(viewController: self, methodTitle: "Error", methodMessage: error?.localizedDescription ?? "Firebase Error")
                    }
                } else {
                    performUIUpdatesOnMain {
                         self.activityIndicator.stopAnimating()
                        self.performSegue(withIdentifier: "toTabbarSegueIdentifier", sender: nil)
                    }
                }
            })
        }else{
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.customAlertView.alertUI(viewController: self, methodTitle: "Error", methodMessage: "Username/Password is empty")
            }
        }
        
        
    }
    
    // MARK: Keyboard Notifications
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        //if(emailTextField.isFirstResponder || passwordTextField.isFirstResponder) {
        if(passwordTextField.isFirstResponder) {
            //view.frame.origin.y = 0 // Review Changed
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardShowNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }
    
    
}

