//
//  ActiveWorkoutView.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var routine: Routine
    @State private var session: WorkoutSession
    @State private var currentTime = Date()
    @State private var timer: Timer?
    @State private var showingAddExercise = false
    @State private var newExerciseName = ""
    @FocusState private var isTextFieldFocused: Bool
    
    init(routine: Routine) {
        self.routine = routine
        _session = State(initialValue: WorkoutSession(routineName: routine.name))
    }
    
    var elapsedTime: String {
        let elapsed = currentTime.timeIntervalSince(session.startTime)
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) / 60 % 60
        let seconds = Int(elapsed) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with timer
                VStack(spacing: 8) {
                    HStack {
                        Text(routine.name.uppercased())
                            .font(.system(size: 18, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
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
                        .padding(.horizontal, 8)
                        
                        Button(action: endWorkout) {
                            Text("[end workout]")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Timer display
                    HStack {
                        Text("┌─")
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text("⏱ \(elapsedTime)")
                            .font(.system(size: 20, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Text("─┐")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Add exercise form
                if showingAddExercise {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("┌─")
                                .foregroundColor(.white.opacity(0.5))
                            Text("ADD EXERCISE")
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
                
                // Exercises
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if routine.exercises.isEmpty {
                            Text("No exercises. Tap [+] to add one.")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                                .padding()
                        } else {
                            ForEach(routine.exercises) { exercise in
                                ActiveExerciseView(exercise: exercise, modelContext: modelContext)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func addExercise() {
        guard !newExerciseName.isEmpty else { return }
        let exercise = Exercise(name: newExerciseName)
        exercise.routine = routine
        routine.exercises.append(exercise)
        modelContext.insert(exercise)
        withAnimation {
            newExerciseName = ""
            showingAddExercise = false
        }
    }
    
    private func endWorkout() {
        session.endWorkout()
        
        // Snapshot completed exercises and sets
        for exercise in routine.exercises {
            let completedSets = exercise.sets.filter { $0.isCompleted }
            if !completedSets.isEmpty {
                let completedExercise = CompletedExercise(name: exercise.name)
                completedExercise.session = session
                
                for set in completedSets {
                    let completedSet = CompletedSet(reps: set.reps, weight: set.weight)
                    completedExercise.completedSets.append(completedSet)
                    modelContext.insert(completedSet)
                    
                    // Reset the set completion status
                    set.isCompleted = false
                }
                
                session.completedExercises.append(completedExercise)
                modelContext.insert(completedExercise)
            }
        }
        
        modelContext.insert(session)
        dismiss()
    }
}

struct ActiveExerciseView: View {
    @Bindable var exercise: Exercise
    let modelContext: ModelContext
    @State private var showingAddSet = false
    @State private var newSetReps = ""
    @State private var newSetWeight = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case reps, weight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("┌─")
                    .foregroundColor(.white.opacity(0.5))
                Text(exercise.name.uppercased())
                    .foregroundColor(.white)
                Spacer()
                Button(action: { 
                    withAnimation {
                        showingAddSet.toggle()
                        if showingAddSet {
                            focusedField = .reps
                        }
                    }
                }) {
                    Text(showingAddSet ? "[-]" : "[+ set]")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
                Text("─┐")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Add set form
            if showingAddSet {
                HStack {
                    Text("│")
                        .foregroundColor(.white.opacity(0.5))
                    Text("Reps:")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 12, design: .monospaced))
                    TextField("0", text: $newSetReps)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .reps)
                        .frame(width: 50)
                    Text("Weight:")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 12, design: .monospaced))
                    TextField("0", text: $newSetWeight)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                        .frame(width: 50)
                    Button(action: addSet) {
                        Text("[save]")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    Text("│")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            if exercise.sets.isEmpty && !showingAddSet {
                HStack {
                    Text("│")
                        .foregroundColor(.white.opacity(0.5))
                    Text("No sets - tap [+ set] to add")
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text("│")
                        .foregroundColor(.white.opacity(0.5))
                }
            } else {
                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    HStack {
                        Text("│")
                            .foregroundColor(.white.opacity(0.5))
                        Button(action: {
                            set.isCompleted.toggle()
                        }) {
                            HStack(spacing: 4) {
                                Text(set.isCompleted ? "[x]" : "[ ]")
                                    .foregroundColor(.white)
                                Text("Set \(index + 1):")
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(set.reps) reps")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("×")
                                    .foregroundColor(.white.opacity(0.5))
                                Text("\(set.weight, specifier: "%.1f") lbs")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        Spacer()
                        Text("│")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            
            HStack {
                Text("└─")
                    .foregroundColor(.white.opacity(0.5))
                let completedCount = exercise.sets.filter { $0.isCompleted }.count
                Text("\(completedCount)/\(exercise.sets.count) completed")
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("─┘")
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .font(.system(size: 14, design: .monospaced))
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
}

#Preview {
    let routine = Routine(name: "Push Day")
    return NavigationStack {
        ActiveWorkoutView(routine: routine)
    }
}

