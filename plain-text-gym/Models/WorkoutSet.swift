//
//  WorkoutSet.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var reps: Int
    var weight: Double
    var isCompleted: Bool
    var timestamp: Date
    
    init(reps: Int = 0, weight: Double = 0.0, isCompleted: Bool = false) {
        self.reps = reps
        self.weight = weight
        self.isCompleted = isCompleted
        self.timestamp = Date()
    }
}

