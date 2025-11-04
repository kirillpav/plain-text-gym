//
//  Routine.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import Foundation
import SwiftData

@Model
final class Routine {
    var name: String
    var exercises: [Exercise]
    var timestamp: Date
    
    init(name: String, exercises: [Exercise] = []) {
        self.name = name
        self.exercises = exercises
        self.timestamp = Date()
    }
}

