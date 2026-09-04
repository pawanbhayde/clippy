//
//  Item.swift
//  clippy
//
//  Created by Pawan Bhayde on 04/09/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
