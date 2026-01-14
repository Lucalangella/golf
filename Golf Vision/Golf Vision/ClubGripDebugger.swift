import SwiftUI
import RealityKit
import RealityKitContent

struct ClubGripDebugger: View {
    // 1. Initial Defaults (Matches your current code)
    @State private var offsetX: Float = 0
    @State private var offsetY: Float = -0.05
    @State private var offsetZ: Float = 0.02
    
    @State private var pitchDeg: Float = 30 // .pi / 6
    @State private var rollDeg: Float = -90 // -.pi / 2
    @State private var yawDeg: Float = 90   // .pi / 2
    
    var body: some View {
        HStack {
            // LEFT SIDE: The 3D Preview
            RealityView { content in
                // 1. Load the Club
                if let club = try? await Entity(named: "Golf_club", in: realityKitContentBundle) {
                    club.name = "GolfClub"
                    content.add(club)
                }
                
                // 2. Create MOCK HAND Visuals
                // Red Sphere = Wrist
                let wrist = ModelEntity(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial(color: .red, isMetallic: false)])
                wrist.name = "MockWrist"
                wrist.position = [0, 1.0, -0.5] // Arbitrary position in space
                content.add(wrist)
                
                // Green Sphere = Middle Finger Knuckle
                let knuckle = ModelEntity(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial(color: .green, isMetallic: false)])
                knuckle.name = "MockKnuckle"
                knuckle.position = [0, 1.0, -0.6] // 10cm forward from wrist
                content.add(knuckle)
                
            } update: { content in
                guard let club = content.entities.first(where: { $0.name == "GolfClub" }),
                      let wrist = content.entities.first(where: { $0.name == "MockWrist" }),
                      let knuckle = content.entities.first(where: { $0.name == "MockKnuckle" }) else { return }
                
                // --- REPLICATING YOUR MATH ---
                
                let wristPos = wrist.position
                let knucklePos = knuckle.position
                
                // Position in the palm (60% toward knuckles from wrist)
                let gripPosition = wristPos + (knucklePos - wristPos) * 0.6
                
                // Base Orientation (Simulating the hand rotation identity)
                // In this mock, the hand is flat, pointing -Z.
                let baseRotation = simd_quatf(angle: 0, axis: [0, 1, 0])
                
                // Apply your Adjustments
                let pitchRotation = simd_quatf(angle: degreesToRad(pitchDeg), axis: [1, 0, 0])
                let rollRotation = simd_quatf(angle: degreesToRad(rollDeg), axis: [0, 0, 1])
                let yawRotation = simd_quatf(angle: degreesToRad(yawDeg), axis: [0, 1, 0])
                
                // Combine rotations
                club.orientation = baseRotation * yawRotation * rollRotation * pitchRotation
                
                // Apply Position + Offset
                // Note: We apply offset relative to world in this simple debugger,
                // but in ARKit it's relative to the hand anchor.
                // To visualize correctly, we just add it to the final calculated position.
                let manualOffset = SIMD3<Float>(offsetX, offsetY, offsetZ)
                club.position = gripPosition + manualOffset
            }
            
            // RIGHT SIDE: The Controls
            VStack(alignment: .leading, spacing: 20) {
                Text("Grip Adjuster").font(.title)
                Divider()
                
                Group {
                    Text("Position Offset")
                    HStack { Text("X"); Slider(value: $offsetX, in: -0.2...0.2) }
                    HStack { Text("Y"); Slider(value: $offsetY, in: -0.2...0.2) }
                    HStack { Text("Z"); Slider(value: $offsetZ, in: -0.2...0.2) }
                }
                
                Divider()
                
                Group {
                    Text("Rotation (Degrees)")
                    HStack { Text("Pitch"); Slider(value: $pitchDeg, in: -180...180) }
                    HStack { Text("Roll");  Slider(value: $rollDeg, in: -180...180) }
                    HStack { Text("Yaw");   Slider(value: $yawDeg, in: -180...180) }
                }
                
                Divider()
                
                // OUTPUT CODE BLOCK
                Text("Copy into ContentView.swift:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(generateCodeSnippet())
                    .font(.system(size: 10, design: .monospaced))
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .textSelection(.enabled)
            }
            .padding()
            .frame(width: 350)
            .background(.regularMaterial)
        }
    }
    
    func degreesToRad(_ deg: Float) -> Float {
        return deg * .pi / 180
    }
    
    func generateCodeSnippet() -> String {
        return """
        let pitchRotation = simd_quatf(angle: \(String(format: "%.3f", degreesToRad(pitchDeg))), axis: [1, 0, 0])
        let rollRotation = simd_quatf(angle: \(String(format: "%.3f", degreesToRad(rollDeg))), axis: [0, 0, 1])
        let yawRotation = simd_quatf(angle: \(String(format: "%.3f", degreesToRad(yawDeg))), axis: [0, 1, 0])
        
        let forwardOffset = SIMD3<Float>(\(String(format: "%.3f", offsetX)), \(String(format: "%.3f", offsetY)), \(String(format: "%.3f", offsetZ)))
        """
    }
}

#Preview(windowStyle: .volumetric) {
    ClubGripDebugger()
}
