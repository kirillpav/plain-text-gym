//
//  WorkoutSessionDetailView.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import SwiftUI
import SwiftData

struct WorkoutSessionDetailView: View {
    let session: WorkoutSession
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(session.routineName.uppercased())
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Session info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("┌─")
                            .foregroundColor(.white.opacity(0.5))
                        Text("WORKOUT SUMMARY")
                            .foregroundColor(.white)
                        Spacer()
                        Text("─┐")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    HStack {
                        Text("│")
                            .foregroundColor(.white.opacity(0.5))
                        Text("Date:")
                            .foregroundColor(.white.opacity(0.7))
                        Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.white)
                        Spacer()
                        Text("│")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    HStack {
                        Text("│")
                            .foregroundColor(.white.opacity(0.5))
                        Text("Duration:")
                            .foregroundColor(.white.opacity(0.7))
                        Text(session.formattedDuration)
                            .foregroundColor(.white)
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
                .padding()
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Exercises
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if session.completedExercises.isEmpty {
                            Text("No exercises completed.")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                                .padding()
                        } else {
                            ForEach(session.completedExercises) { exercise in
                                CompletedExerciseView(exercise: exercise)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CompletedExerciseView: View {
    let exercise: CompletedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("┌─")
                    .foregroundColor(.white.opacity(0.5))
                Text(exercise.name.uppercased())
                    .foregroundColor(.white)
                Spacer()
                Text("─┐")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            ForEach(Array(exercise.completedSets.enumerated()), id: \.element.id) { index, set in
                HStack {
                    Text("│")
                        .foregroundColor(.white.opacity(0.5))
                    Text("[x]")
                        .foregroundColor(.white)
                    Text("Set \(index + 1):")
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(set.reps) reps")
                        .foregroundColor(.white.opacity(0.8))
                    Text("×")
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(set.weight, specifier: "%.1f") lbs")
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("│")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            HStack {
                Text("└─")
                    .foregroundColor(.white.opacity(0.5))
                Text("\(exercise.completedSets.count) sets")
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("─┘")
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .font(.system(size: 14, design: .monospaced))
    }
}

#Preview {
    let session = WorkoutSession(routineName: "Push Day")
    session.endWorkout()
    
    return NavigationStack {
        WorkoutSessionDetailView(session: session)
    }
}

