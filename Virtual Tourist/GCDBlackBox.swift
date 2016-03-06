//
//  GCDBlackBox.swift
//  Virtual Tourist
//
//  Created by Imanol Viana Sánchez on 3/3/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation

func performUIUpdates(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}