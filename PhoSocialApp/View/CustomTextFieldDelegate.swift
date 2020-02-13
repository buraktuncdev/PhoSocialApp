//
//  CustomTextFieldDelegate.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 10.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import Foundation
import UIKit

class CustomTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
}
