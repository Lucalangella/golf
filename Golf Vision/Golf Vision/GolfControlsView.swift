import SwiftUI

struct GolfControlsView: View {
    @Bindable var config: GolfConfig
    
    // Environment variables to open/close the VR space
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    // Track if the space is currently open
    @State private var isSpaceOpen = false

    var body: some View {
        VStack(spacing: 20) {
            
            // --- NEW: LAUNCHER SECTION ---
            Text("Golf Debugger")
                .font(.largeTitle)
                .bold()
            
            Button(isSpaceOpen ? "Stop Golfing" : "Start Golfing") {
                Task {
                    if isSpaceOpen {
                        await dismissImmersiveSpace()
                        isSpaceOpen = false
                    } else {
                        // This ID must match what is in GolfApp.swift
                        let result = await openImmersiveSpace(id: "GolfSpace")
                        if result == .opened {
                            isSpaceOpen = true
                        }
                    }
                }
            }
            .padding()
            .background(isSpaceOpen ? Color.red : Color.green)
            .foregroundStyle(.white)
            .cornerRadius(10)
            
            Divider()
            
            // --- EXISTING: CONTROLS SECTION ---
            
            // Only show sliders if space is open to save clutter
            if isSpaceOpen {
                ScrollView {
                    VStack(spacing: 15) {
                        // Position Sliders
                        Group {
                            Text("Position Offset (Meters)").font(.headline)
                            SliderRow(label: "X", value: $config.posX, range: -0.5...0.5)
                            SliderRow(label: "Y", value: $config.posY, range: -0.5...0.5)
                            SliderRow(label: "Z", value: $config.posZ, range: -0.5...0.5)
                        }
                        
                        Divider()
                        
                        // Rotation Sliders
                        Group {
                            Text("Rotation Offset (Degrees)").font(.headline)
                            SliderRow(label: "X", value: $config.rotX, range: -180...180)
                            SliderRow(label: "Y", value: $config.rotY, range: -180...180)
                            SliderRow(label: "Z", value: $config.rotZ, range: -180...180)
                        }
                        
                        Divider()
                        
                        // Output
                        VStack(alignment: .leading) {
                            Text("Copy these values:").font(.caption).foregroundStyle(.secondary)
                            Text("Pos: \(config.posX, specifier: "%.3f"), \(config.posY, specifier: "%.3f"), \(config.posZ, specifier: "%.3f")")
                                .monospaced()
                            Text("Rot: \(config.rotX, specifier: "%.1f"), \(config.rotY, specifier: "%.1f"), \(config.rotZ, specifier: "%.1f")")
                                .monospaced()
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .padding()
                }
            } else {
                Text("Open the Space to start calibrating")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 400, height: 600)
    }
}

// Helper for sliders
struct SliderRow: View {
    let label: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    
    var body: some View {
        HStack {
            Text(label).bold().frame(width: 20)
            Slider(value: $value, in: range)
            Text("\(value, specifier: "%.2f")").monospaced().frame(width: 50)
        }
    }
}
