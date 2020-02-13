//
//  UploadViewController.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 6.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Network

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    let monitor = NWPathMonitor()
    
    let customTextFieldDelegate = CustomTextFieldDelegate()
    let customAlertView = CustomAlertView()
    // MARK: Activity Indicator For Uploading File
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let locationManager = CLLocationManager()
    
    
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
    
      // MARK: Keyboard Notifications
      @objc func keyboardWillHide(_ notification:Notification) {
          view.frame.origin.y = 0
      }
      
      @objc func keyboardWillShow(_ notification:Notification) {
          if(commentTextField.isFirstResponder) {
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
      
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                print("Internet connection is on.")
            } else {
                performUIUpdatesOnMain {
                    self.customAlertView.alertUI(viewController: self, methodTitle: "Internet Error", methodMessage: "There's no internet connection. Please Check")
                }
            }
        }
        
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        monitor.start(queue: queue)
        
        // For use when the app is open & in the background
        locationManager.requestWhenInUseAuthorization()
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
        
        uploadButton.isHidden = true
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        commentTextField.delegate = customTextFieldDelegate
    }
    
    // Print out the location to the console
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
            latitudeLabel.text = "Your Latitude: \(location.coordinate.latitude)"
            longitudeLabel.text = "Your Longitude: \(location.coordinate.longitude)"
            
        }
    }
    
    
    // MARK: Pick an image from Photo Library
    @objc func chooseImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        uploadButton.isHidden = false
    }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
        var currentLoc: CLLocation!
        
        let storage = Storage.storage()
        let storageReferenfe = storage.reference()   // Main Path
        let mediaFolder = storageReferenfe.child("media")
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = .green
        view.addSubview(self.activityIndicator)
        activityIndicator.startAnimating()
        
        // MARK: Convert to DATA
        
        if let currentLoc = locationManager.location {
            let latit = currentLoc.coordinate.latitude
            let longit = currentLoc.coordinate.longitude
            
            if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
                
                let uuid = UUID().uuidString  // unique id string
                let imageReference = mediaFolder.child("\(uuid).jpg")
                
                // MARK: UPLOAD AN IMAGE TO FIREBASE STORAGE WITH UUID
                
                imageReference.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        performUIUpdatesOnMain {
                            self.customAlertView.alertUI(viewController: self, methodTitle: "Error", methodMessage: error?.localizedDescription ?? "Firebase File Upload Error")
                        }
                    } else {
                        imageReference.downloadURL { (url, error) in
                            if error == nil {
                                self.activityIndicator.stopAnimating()
                                
                                let imageUrl = url?.absoluteString
                                let locationInstance = Location(latitude: latit, longitude: longit)
                                let postInstance = Post(imageUrl: imageUrl!, postedBy:  Auth.auth().currentUser!.email, postComment: self.commentTextField.text!, date: Date(), likes: 0,
                                                        latitude:locationInstance.latitude, longitude: locationInstance.longitude)
                                
                                //MARK: FIRESTORE DATABASE ADD DOCUMENT AS DICTIONARY
                                let firestoreDatabase = Firestore.firestore()
                                
                                var firestoreReference: DocumentReference? = nil
                                
                                var firestorePost = ["imageUrl": postInstance.imageUrl, "postedBy": postInstance.postedBy, "postComment": postInstance.postComment, "date": postInstance.date, "likes": postInstance.likes, "latitude": postInstance.latitude, "longitude": postInstance.longitude] as [String:Any]
                                
                                
                                firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                    if error != nil {
                                        performUIUpdatesOnMain {
                                            self.customAlertView.alertUI(viewController: self, methodTitle: "Error", methodMessage: error?.localizedDescription ?? "Firebase File Upload Error")
                                        }
                                    } else {
                                        self.imageView.image = UIImage(named: "tapme")
                                        self.commentTextField.text = ""
                                        self.tabBarController?.selectedIndex = 0
                                        
                                        // MARK: Notification for Upload new Post
                                        NotificationCenter.default.post(name: NSNotification.Name("newPost"), object: nil)
                                        
                                    }
                                })
                            }
                        }
                    }
                    
                }
                
            }
        }
    }
    
}
