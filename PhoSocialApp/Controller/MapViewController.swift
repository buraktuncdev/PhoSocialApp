//
//  MapViewController.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 10.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import UIKit
import MapKit
import Firebase 

class MapViewController: UIViewController,MKMapViewDelegate {
    // MARK: - Variables
    @IBOutlet weak var mapView: MKMapView!
    var pinAnnotation: MKPointAnnotation? = nil
    let customAlertView = CustomAlertView()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var documentIdArray = [String]()
    var resultArr = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let pins = getPinFromFirestore()
        showPins(pins)
    }
    
    func showPins(_ pins: [CLLocationCoordinate2D]) {
        for pin in pins {
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            annotation.title = "\(pin.latitude):\(pin.longitude)"
            print("PIN: \(pin)" )
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
          let pins = getPinFromFirestore()
          showPins(pins)
    }
    
    
 
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
   

    
    
    // MARK: Listen Firestore
    @objc func getPinFromFirestore() -> [CLLocationCoordinate2D] {
        let fireStoreDatabase = Firestore.firestore()
        // let settings = fireStoreDatabase.settings
        // settings.areTimestampsInSnapshotsEnabled  //deprecated
        fireStoreDatabase.collection("Posts")
            .order(by: "date", descending: true)
            .addSnapshotListener { (snapshot, error) in
                if error != nil {
                    performUIUpdatesOnMain {
                        self.customAlertView.alertUI(viewController: self, methodTitle: "Alert Message", methodMessage: error?.localizedDescription ?? "Post Listener Error")
                    }
                } else {
                     self.resultArr.removeAll(keepingCapacity: false)
                    // Document Array
                    if snapshot?.isEmpty != true && snapshot != nil{
                    
                        self.latitudeArray.removeAll(keepingCapacity: false)
                        self.longitudeArray.removeAll(keepingCapacity: false)
                        for document in snapshot!.documents {
                            let documentID = document.documentID
                            self.documentIdArray.append(documentID)
                            
                            if let latitude = document.get("latitude") as? Double {
                                self.latitudeArray.append(latitude)
                                if let longitude = document.get("longitude") as? Double {
                                    self.longitudeArray.append(longitude)
                                    self.resultArr.append(CLLocationCoordinate2DMake(latitude, longitude))
                                }
                            }
                        }
                    }
                }
        }
        
        return self.resultArr
    }
    
    
    
    
    
    
    
}
