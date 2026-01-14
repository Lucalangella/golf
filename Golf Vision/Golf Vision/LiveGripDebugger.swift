import SwiftUI
import RealityKit
import ARKit

struct LiveGripDebugger: View {
    // 1. SLIDER VARIABLES
    @State private var offsetX: Float = 0
    @State private var offsetY: Float = -0.05
    @State private var offsetZ: Float = 0.02
    
    @State private var pitchDeg: Float = 30
    @State private var rollDeg: Float = -90
    @State private var yawDeg: Float = 90
    
    // 2. AR STATE
    @State private var latestHandAnchor: HandAnchor?
    @State private var golfClub: Entity?
    
    var body: some View {
        ZStack {
            // LAYER 1: The AR World
            RealityView { content in
                print("DEBUG: RealityView started loading...")
                
                // Try to load the club, catch errors
                do {
                    // Attempt to load the model
                    let model = try await Entity(named: "Golf_club")
                    model.name = "GolfClub"
                    content.add(model)
                    golfClub = model
                    print("DEBUG: ✅ SUCCESS - Golf_club loaded!")
                } catch {
                    print("DEBUG: ❌ FAILED to load Golf_club: \(error.localizedDescription)")
                    print("DEBUG: ⚠️ Loading PLACEHOLDER Box instead.")
                    
                    // FALLBACK: Create a Blue Box if file fails
                    let mesh = MeshResource.generateBox(size: 0.05, cornerRadius: 0.01)
                    let material = SimpleMaterial(color: .blue, isMetallic: false)
                    let placeholder = ModelEntity(mesh: mesh, materials: [material])
                    placeholder.name = "PlaceholderBox"
                    content.add(placeholder)
                    golfClub = placeholder
                }
            } update: { content in
                // This updates every frame
                guard let club = golfClub,
                      let handAnchor = latestHandAnchor,
                      let skeleton = handAnchor.handSkeleton else { return }
                
                // Get Joint Positions
                let rootTransform = handAnchor.originFromAnchorTransform
                let wrist = skeleton.joint(.wrist)
                let knuckle = skeleton.joint(.middleFingerKnuckle)
                
                let wristTransform = rootTransform * wrist.anchorFromJointTransform
                let knuckleTransform = rootTransform * knuckle.anchorFromJointTransform
                
                let wristPos = SIMD3<Float>(wristTransform.columns.3.x, wristTransform.columns.3.y, wristTransform.columns.3.z)
                let knucklePos = SIMD3<Float>(knuckleTransform.columns.3.x, knuckleTransform.columns.3.y, knuckleTransform.columns.3.z)
                
                // Calc Base Position (60% up the palm)
                let basePos = wristPos + (knucklePos - wristPos) * 0.6
                
                // Apply Slider Adjustments
                let pitch = simd_quatf(angle: degreesToRad(pitchDeg), axis: [1, 0, 0])
                let roll = simd_quatf(angle: degreesToRad(rollDeg), axis: [0, 0, 1])
                let yaw = simd_quatf(angle: degreesToRad(yawDeg), axis: [0, 1, 0])
                
                // Set Orientation & Position
                let handRotation = Transform(matrix: wristTransform).rotation
                club.orientation = handRotation * yaw * roll * pitch
                
                let manualOffset = SIMD3<Float>(offsetX, offsetY, offsetZ)
                club.position = basePos + manualOffset
            }
            .task {
                print("DEBUG: Starting AR Session...")
                await runARSession()
            }
            
            // LAYER 2: Controls
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Live Debugger").font(.headline)
                        Text(golfClub == nil ? "Waiting for Model..." : "Model Active").font(.caption).foregroundStyle(.secondary)
                        
                        Group {
                            Text("Offset X: \(offsetX, specifier: "%.3f")"); Slider(value: $offsetX, in: -0.2...0.2)
                            Text("Offset Y: \(offsetY, specifier: "%.3f")"); Slider(value: $offsetY, in: -0.2...0.2)
                            Text("Offset Z: \(offsetZ, specifier: "%.3f")"); Slider(value: $offsetZ, in: -0.2...0.2)
                        }
                        Divider()
                        Group {
                            Text("Pitch: \(pitchDeg, specifier: "%.0f")"); Slider(value: $pitchDeg, in: -180...180)
                            Text("Roll: \(rollDeg, specifier: "%.0f")"); Slider(value: $rollDeg, in: -180...180)
                            Text("Yaw: \(yawDeg, specifier: "%.0f")"); Slider(value: $yawDeg, in: -180...180)
                        }
                    }
                    .padding()
                    .frame(width: 250)
                    .background(.regularMaterial)
                    .cornerRadius(16)
                    .padding()
                }
            }
        }
    }
    
    func runARSession() async {
        let session = ARKitSession()
        let handTracking =
