//
//  GCDBlackBox.swift
//  PhoSocialApp
//
//  Created by Burak Tunc on 11.02.2020.
//  Copyright © 2020 Burak Tunc. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
