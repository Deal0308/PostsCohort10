//
//  Item.swift
//  PostsCohort10
//
//  Created by Michael Deal on 8/18/26.
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
