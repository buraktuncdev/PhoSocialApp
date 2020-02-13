//
//  SceneDelegate.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 5.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // MARK: Check User is Authenticated
        
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            let board = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = board.instantiateViewController(identifier: "tabbarStoryboardID") as! UITabBarController
            window?.rootViewController = tabBar
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
  
    
}

