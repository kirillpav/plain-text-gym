//
//  RoutineListView.swift
//  plain-text-gym
//
//  Created by Kirill Pavlov on 11/2/25.
//

import SwiftUI
import SwiftData

struct RoutineListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.timestamp, order: .reverse) private var routines: [Routine]
    @State private var showingAddRoutine = false
    @State private var newRoutineName = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("log")
                        .font(.system(size: 20, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: { 
                        withAnimation {
                            showingAddRoutine.toggle()
                            if showingAddRoutine {
                                isTextFieldFocused = true
                            }
                        }
                    }) {
                        Text(showingAddRoutine ? "[-]" : "[+]")
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Add routine form
                if showingAddRoutine {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("┌─")
                                .foregroundColor(.white.opacity(0.5))
                            Text("NEW ROUTINE")
                                .foregroundColor(.white)
                            Spacer()
                            Text("─┐")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack {
                            Text("│")
                                .foregroundColor(.white.opacity(0.5))
                            TextField("Name", text: $newRoutineName)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .focused($isTextFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    addRoutine()
                                }
                            Text("│")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack {
                            Text("└─")
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Button(action: addRoutine) {
                                Text("[save]")
                                    .foregroundColor(.white)
                            }
                            Button(action: {
                                withAnimation {
                                    showingAddRoutine = false
                                    newRoutineName = ""
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
                
                // Routines list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if routines.isEmpty {
                            Text("No routines. Tap [+] to create one.")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                                .padding()
                        } else {
                            ForEach(routines) { routine in
                                NavigationLink(destination: RoutineDetailView(routine: routine)) {
                                    RoutineRowView(routine: routine)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func addRoutine() {
        guard !newRoutineName.isEmpty else { return }
        let routine = Routine(name: newRoutineName)
        modelContext.insert(routine)
        withAnimation {
            newRoutineName = ""
            showingAddRoutine = false
        }
    }
}

struct RoutineRowView: View {
    let routine: Routine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("┌─")
                    .foregroundColor(.white.opacity(0.5))
                Text(routine.name.uppercased())
                    .foregroundColor(.white)
                Spacer()
                Text("─┐")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack {
                Text("│")
                    .foregroundColor(.white.opacity(0.5))
                Text("\(routine.exercises.count) exercises")
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
        RoutineListView()
            .modelContainer(for: Routine.self, inMemory: true)
    }
}

