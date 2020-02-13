//
//  FeedViewController.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 6.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import Network

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var userEmailArray = [String]()
    var commentArray = [String]()
    var likeArray = [Int]()
    var imageArray = [String]()
    let customAlertView = CustomAlertView()
    var documentIdArray = [String]()
    let monitor = NWPathMonitor()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var locationArray = [Location]()
    var pinModel = PinModel()
    
    static func shared() -> FeedViewController {
        struct Singleton {
            static var shared = FeedViewController()
        }
        return Singleton.shared
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
            activityIndicator.center = self.view.center
               activityIndicator.hidesWhenStopped = true
               activityIndicator.style = UIActivityIndicatorView.Style.large
               activityIndicator.color = .green
               view.addSubview(self.activityIndicator)
               activityIndicator.startAnimating()
        
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
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getDataFromFirestore()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector
            (FeedViewController.getDataFromFirestore), name: NSNotification.Name("newPost"), object: nil)
    }
    
    // MARK: Listen Firestore
    @objc func getDataFromFirestore() {
        
        let fireStoreDatabase = Firestore.firestore()
        // let settings = fireStoreDatabase.settings
        // settings.areTimestampsInSnapshotsEnabled  //deprecated
        fireStoreDatabase.collection("Posts")
            .order(by: "date", descending: true)
            .addSnapshotListener { (snapshot, error) in
                if error != nil {
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.customAlertView.alertUI(viewController: self, methodTitle: "Alert Message", methodMessage: error?.localizedDescription ?? "Post Listener Error")
                    }
                } else {
                    // Document Array
                    if snapshot?.isEmpty != true && snapshot != nil{
                        
                        self.userEmailArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.likeArray.removeAll(keepingCapacity: false)
                        self.imageArray.removeAll(keepingCapacity: false)
                        self.documentIdArray.removeAll(keepingCapacity: false)
                        self.latitudeArray.removeAll(keepingCapacity: false)
                        self.longitudeArray.removeAll(keepingCapacity: false)
                        
                        
                        for document in snapshot!.documents {
                            
                            let documentID = document.documentID
                            self.documentIdArray.append(documentID)
                            
                            if let postedBy = document.get("postedBy") as? String {
                                self.userEmailArray.append(postedBy)
                            }
                            
                            if let postComment = document.get("postComment") as? String {
                                self.commentArray.append(postComment)
                            }
                            
                            if let likes = document.get("likes") as? Int {
                                self.likeArray.append(likes)
                            }
                            
                            if let imageUrl = document.get("imageUrl") as? String {
                                self.imageArray.append(imageUrl)
                            }
                            
                            if let latitude = document.get("latitude") as? Double {
                                self.latitudeArray.append(latitude)
                                self.pinModel.latitudeArr = self.latitudeArray
                            }
                            
                            if let longitude = document.get("longitude") as? Double {
                                self.longitudeArray.append(longitude)
                                self.pinModel.longitudeArr = self.longitudeArray
                            }
                            
                        }
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                      
                    }
                    else{
                        
                        self.customAlertView.alertUI(viewController: self, methodTitle: "Alert Message", methodMessage: "There is no post")
                        self.activityIndicator.stopAnimating()
                    }
                }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! FeedTableViewCell
        cell.emailLabel.text = userEmailArray[indexPath.row]
        cell.likedCountLabel.text = String(likeArray[indexPath.row])
        cell.commentLabel.text = "\(userEmailArray[indexPath.row].split(separator: "@", maxSplits: 1, omittingEmptySubsequences: true).first!.uppercased()): " + commentArray[indexPath.row]
        cell.postImageView?.sd_setImage(with: URL(string: self.imageArray[indexPath.row]))
        cell.documentIdLabel.text = documentIdArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 410
    }
    
}
