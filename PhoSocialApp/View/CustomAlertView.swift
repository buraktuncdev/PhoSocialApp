//
//  AlertView.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 6.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import Foundation

import UIKit

//MARK: Custom Alert View
class CustomAlertView {
    
    func alertUI(viewController: UIViewController, methodTitle:String, methodMessage:String) {
          let avController = UIAlertController()
        avController.title = methodTitle
        avController.message = methodMessage
          
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
              action in avController.dismiss(animated: true, completion: nil)
            viewController.navigationController?.popViewController(animated: true)
          }
          avController.addAction(okAction)
          viewController.present(avController, animated: true, completion: nil)
      }

}

