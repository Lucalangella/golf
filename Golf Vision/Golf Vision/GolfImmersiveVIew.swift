import SwiftUI
import RealityKit

struct GolfImmersiveView: View {
    // We no longer need the 'config' variable since we are hardcoding values
    
    var body: some View {
        RealityView { content in
            // 1. Create Hand Anchor (Right Hand)
            let handAnchor = AnchorEntity(.hand(.right, location: .palm))
            
            // 2. Load the Golf Club
            if let club = try? await Entity(named: "Golf_club") {
                
                // --- APPLY YOUR CALIBRATED VALUES HERE ---
                
                // Position (Meters)
                club.position = SIMD3<Float>(0.022, 0.029, -0.015)
                
                // Rotation (Degrees converted to Quaternion)
                // Values: X: -105.6, Y: -172.0, Z: 79.1
                club.orientation = convertDegreesToQuaternion(x: -105.6, y: -172.0, z: 79.1)
                
                // ----------------------------------------
                
                handAnchor.addChild(club)
            } else {
                print("Error: 'Golf_club' model not found in app bundle.")
            }
            
            // 3. Add to Scene
            content.add(handAnchor)
        }
    }
    
    // Helper function to keep the math clean
    func convertDegreesToQuaternion(x: Float, y: Float, z: Float) -> simd_quatf {
        let angleX = x * .pi / 180
        let angleY = y * .pi / 180
        let angleZ = z * .pi / 180
        
        // Create quaternion (Order: Z, Y, X)
        return simd_quatf(angle: angleX, axis: [1, 0, 0]) *
               simd_quatf(angle: angleY, axis: [0, 1, 0]) *
               simd_quatf(angle: angleZ, axis: [0, 0, 1])
    }
}
