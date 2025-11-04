//
//  RoutineDetailView.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import SwiftUI
import SwiftData

struct RoutineDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var routine: Routine
    @State private var showingAddExercise = false
    @State private var newExerciseName = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with routine name
                HStack {
                    Text(routine.name.uppercased())
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: { 
                        withAnimation {
                            showingAddExercise.toggle()
                            if showingAddExercise {
                                isTextFieldFocused = true
                            }
                        }
                    }) {
                        Text(showingAddExercise ? "[-]" : "[+]")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                
                // Start workout button
                HStack {
                    Spacer()
                    NavigationLink(destination: ActiveWorkoutView(routine: routine)) {
                        HStack {
                            Text("┌─")
                                .foregroundColor(.white.opacity(0.5))
                            Text("[START WORKOUT]")
                                .foregroundColor(.white)
                            Text("─┐")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .font(.system(size: 16, design: .monospaced))
                        .padding(.vertical, 8)
                    }
                    Spacer()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Add exercise form
                if showingAddExercise {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("┌─")
                                .foregroundColor(.white.opacity(0.5))
                            Text("NEW EXERCISE")
                                .foregroundColor(.white)
                            Spacer()
                            Text("─┐")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack {
                            Text("│")
                                .foregroundColor(.white.opacity(0.5))
                            TextField("Name", text: $newExerciseName)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .focused($isTextFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    addExercise()
                                }
                            Text("│")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack {
                            Text("└─")
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Button(action: addExercise) {
                                Text("[save]")
                                    .foregroundColor(.white)
                            }
                            Button(action: {
                                withAnimation {
                                    showingAddExercise = false
                                    newExerciseName = ""
                                }
                            }) {
                                Text("[cancel]")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Text("─┘")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .font(.system(size: 14, design: .monospaced))
                    .padding()
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Exercises list
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if routine.exercises.isEmpty {
                            Text("No exercises. Tap [+] to add one.")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                                .padding()
                        } else {
                            ForEach(routine.exercises.sorted(by: { $0.order < $1.order })) { exercise in
                                VStack(alignment: .leading, spacing: 4) {
                                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                        ExerciseRowView(exercise: exercise)
                                    }
                                    
                                    // Delete button
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            deleteExercise(exercise)
                                        }) {
                                            Text("[delete]")
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(.red.opacity(0.7))
                                        }
                                        .padding(.trailing, 8)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addExercise() {
        guard !newExerciseName.isEmpty else { return }
        let nextOrder = (routine.exercises.map { $0.order }.max() ?? -1) + 1
        let exercise = Exercise(name: newExerciseName, order: nextOrder)
        exercise.routine = routine
        routine.exercises.append(exercise)
        modelContext.insert(exercise)
        withAnimation {
            newExerciseName = ""
            showingAddExercise = false
        }
    }
    
    private func deleteExercise(_ exercise: Exercise) {
        if let index = routine.exercises.firstIndex(where: { $0.id == exercise.id }) {
            routine.exercises.remove(at: index)
            modelContext.delete(exercise)
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("┌─")
                    .foregroundColor(.white.opacity(0.5))
                Text(exercise.name.uppercased())
                    .foregroundColor(.white)
                Spacer()
                Text("─┐")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack {
                Text("│")
                    .foregroundColor(.white.opacity(0.5))
                if exercise.sets.isEmpty {
                    Text("No sets configured")
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    Text("\(exercise.sets.count) sets")
                        .foregroundColor(.white.opacity(0.7))
                }
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Routine.self, configurations: config)
    let routine = Routine(name: "Push Day")
    
    return NavigationStack {
        RoutineDetailView(routine: routine)
            .modelContainer(container)
    }
}

