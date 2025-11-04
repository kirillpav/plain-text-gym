//
//  Exercise.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var sets: [WorkoutSet]
    var routine: Routine?
    var timestamp: Date
    
    init(name: String, sets: [WorkoutSet] = []) {
        self.name = name
        self.sets = sets
        self.timestamp = Date()
    }
}

