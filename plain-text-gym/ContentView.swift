//
//  ContentView.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                RoutineListView()
            }
            .tabItem {
                Label("Routines", systemImage: "list.bullet")
            }
            
            NavigationStack {
                WorkoutHistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Routine.self, inMemory: true)
}
