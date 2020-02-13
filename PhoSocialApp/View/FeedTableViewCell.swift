//
//  FeedTableViewCell.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 6.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import UIKit
import Firebase

class FeedTableViewCell: UITableViewCell {
    
    //@IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likedCountLabel: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel!
    
    @IBOutlet weak var likeButtonLabel: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: INSERT AND SELECT LIKE COUNT
    @IBAction func likeButtonClicked(_ sender: Any) {
        print("Like Button Clicked")
        let fireStoreDatabase = Firestore.firestore()
        
        if let likeCount = Int(likedCountLabel.text!) {
            
            let likeStore = ["likes": likeCount + 1] as [String : Any]
            
            // MARK: UPDATE LIKES ATTRIBUTE ( FIREBASE SET DATA WITH MERGE)
            fireStoreDatabase.collection("Posts").document(documentIdLabel.text!).setData(likeStore, merge: true)
            
            // Like only once for each user
            likeButtonLabel.isEnabled = false
            
            
        }
        
        
    }
    
    
}

