//
//  WorkoutHistoryView.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutSession.startTime, order: .reverse) private var sessions: [WorkoutSession]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("WORKOUT HISTORY")
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Sessions list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if sessions.isEmpty {
                            Text("No workouts logged yet.")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                                .padding()
                        } else {
                            ForEach(sessions) { session in
                                NavigationLink(destination: WorkoutSessionDetailView(session: session)) {
                                    WorkoutSessionRowView(session: session)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct WorkoutSessionRowView: View {
    let session: WorkoutSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("┌─")
                    .foregroundColor(.white.opacity(0.5))
                Text(session.routineName.uppercased())
                    .foregroundColor(.white)
                Spacer()
                Text("─┐")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack {
                Text("│")
                    .foregroundColor(.white.opacity(0.5))
                Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("│")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack {
                Text("│")
                    .foregroundColor(.white.opacity(0.5))
                Text("Duration: \(session.formattedDuration)")
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("│")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack {
                Text("│")
                    .foregroundColor(.white.opacity(0.5))
                Text("\(session.completedExercises.count) exercises")
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("│")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack {
                Text("└─")
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("─┘")
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .font(.system(size: 14, design: .monospaced))
    }
}

#Preview {
    NavigationStack {
        WorkoutHistoryView()
            .modelContainer(for: WorkoutSession.self, inMemory: true)
    }
}

