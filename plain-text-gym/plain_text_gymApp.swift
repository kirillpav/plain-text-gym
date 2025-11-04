//
//  plain_text_gymApp.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import SwiftUI
import SwiftData

@main
struct plain_text_gymApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Routine.self,
            Exercise.self,
            WorkoutSet.self,
            WorkoutSession.self,
            CompletedExercise.self,
            CompletedSet.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If migration fails, delete the old database and create a new one
            print("Failed to create ModelContainer with existing data: \(error)")
            print("Attempting to recreate database...")
            
            // Get the store URL and delete it
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            
            // Try again with a fresh database
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
