//
//  Location.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 10.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import Foundation

class Location: Codable{
    let latitude:Double?
    let longitude:Double?

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    
    }
}

class PinModel: Codable {
    var latitudeArr: [Double]?
    var longitudeArr: [Double]?
    
   
    
}
