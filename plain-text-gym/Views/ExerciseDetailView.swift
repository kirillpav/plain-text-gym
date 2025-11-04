//
//  ExerciseDetailView.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var exercise: Exercise
    @State private var showingAddSet = false
    @State private var newSetReps = ""
    @State private var newSetWeight = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case reps, weight
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(exercise.name.uppercased())
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: { 
                        withAnimation {
                            showingAddSet.toggle()
                            if showingAddSet {
                                focusedField = .reps
                            }
                        }
                    }) {
                        Text(showingAddSet ? "[-]" : "[+]")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Add set form
                if showingAddSet {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("┌─")
                                .foregroundColor(.white.opacity(0.5))
                            Text("NEW SET")
                                .foregroundColor(.white)
                            Spacer()
                            Text("─┐")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack {
                            Text("│")
                                .foregroundColor(.white.opacity(0.5))
                            Text("Reps:")
                                .foregroundColor(.white.opacity(0.7))
                            TextField("0", text: $newSetReps)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .reps)
                                .frame(width: 60)
                            Text("│")
                                .foregroundColor(.white.opacity(0.5))
                            Text("Weight:")
                                .foregroundColor(.white.opacity(0.7))
                            TextField("0", text: $newSetWeight)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .weight)
                                .frame(width: 60)
                            Text("lbs")
                                .foregroundColor(.white.opacity(0.5))
                            Text("│")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack {
                            Text("└─")
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Button(action: addSet) {
                                Text("[save]")
                                    .foregroundColor(.white)
                            }
                            Button(action: {
                                withAnimation {
                                    showingAddSet = false
                                    newSetReps = ""
                                    newSetWeight = ""
                                    focusedField = nil
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
                
                // Sets list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if exercise.sets.isEmpty {
                            Text("No sets logged. Tap [+] to add one.")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                                .padding()
                        } else {
                            Text("NOTE: Sets can only be marked complete during an active workout")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.bottom, 8)
                            
                            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                                SetRowView(
                                    setNumber: index + 1,
                                    set: set,
                                    onToggle: {
                                        toggleSet(set)
                                    },
                                    onDelete: {
                                        deleteSet(set)
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addSet() {
        let reps = Int(newSetReps) ?? 0
        let weight = Double(newSetWeight) ?? 0.0
        guard reps > 0 || weight > 0 else { return }
        
        let set = WorkoutSet(reps: reps, weight: weight)
        exercise.sets.append(set)
        modelContext.insert(set)
        withAnimation {
            newSetReps = ""
            newSetWeight = ""
            showingAddSet = false
            focusedField = nil
        }
    }
    
    private func toggleSet(_ set: WorkoutSet) {
        set.isCompleted.toggle()
    }
    
    private func deleteSet(_ set: WorkoutSet) {
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
            exercise.sets.remove(at: index)
            modelContext.delete(set)
        }
    }
}

struct SetRowView: View {
    let setNumber: Int
    let set: WorkoutSet
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                HStack(spacing: 4) {
                    Text("[ ]")
                        .foregroundColor(.white.opacity(0.3))
                    Text("Set \(setNumber)")
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Text("[delete]")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
            .font(.system(size: 14, design: .monospaced))
            
            HStack {
                Text("│")
                    .foregroundColor(.white.opacity(0.3))
                Text("Reps: \(set.reps)")
                    .foregroundColor(.white.opacity(0.7))
                Text("│")
                    .foregroundColor(.white.opacity(0.3))
                Text("Weight: \(set.weight, specifier: "%.1f") lbs")
                    .foregroundColor(.white.opacity(0.7))
            }
            .font(.system(size: 13, design: .monospaced))
            
            Divider()
                .background(Color.white.opacity(0.2))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, configurations: config)
    let exercise = Exercise(name: "Bench Press")
    
    return NavigationStack {
        ExerciseDetailView(exercise: exercise)
            .modelContainer(container)
    }
}

