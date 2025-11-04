//
//  WorkoutSession.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var routineName: String
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var completedExercises: [CompletedExercise]
    
    init(routineName: String, startTime: Date = Date()) {
        self.routineName = routineName
        self.startTime = startTime
        self.endTime = nil
        self.duration = 0
        self.completedExercises = []
    }
    
    func endWorkout() {
        self.endTime = Date()
        self.duration = endTime!.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

@Model
final class CompletedExercise {
    var name: String
    var completedSets: [CompletedSet]
    var session: WorkoutSession?
    
    init(name: String, completedSets: [CompletedSet] = []) {
        self.name = name
        self.completedSets = completedSets
    }
}

@Model
final class CompletedSet {
    var reps: Int
    var weight: Double
    var completedAt: Date
    
    init(reps: Int, weight: Double, completedAt: Date = Date()) {
        self.reps = reps
        self.weight = weight
        self.completedAt = completedAt
    }
}

