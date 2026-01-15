import SwiftUI
import RealityKit

struct GolfImmersiveView: View {
    @State private var collisionSubscription: EventSubscription?
    @State private var hitSound: AudioFileResource?
    
    var body: some View {
        RealityView { content in
            // 1. Load Audio
            if let sound = try? await AudioFileResource(named: "golf_hit.mp3") {
                self.hitSound = sound
            }
            
            // 2. Create Hand Anchor
            let handAnchor = AnchorEntity(.hand(.right, location: .palm))
            
            // 3. Setup Club
            if let club = try? await Entity(named: "Golf_club") {
                club.name = "Club"
                
                // --- FIX 1: SCALE THE CLUB ---
             
                club.scale = SIMD3<Float>(repeating: 2.0)
                
                // --- FIX 2: ROTATION ADJUSTMENT ---
                // We rotate it to point "down" from your palm (Grip style)
                // You might need to tweak these slightly, but this is a standard starting grip.
                club.orientation = convertDegreesToQuaternion(x: 0, y: -90, z: 90)
                
                // Adjust position to fit snugly in the palm
                club.position = SIMD3<Float>(0, 0, 0)
                
                setupClubPhysics(for: club)
                handAnchor.addChild(club)
            }
            
            // 4. Create Floor
            let floor = createFloor()
            // --- FIX 3: MOVE FLOOR DOWN ---
            // Move floor 1.6 meters down so it sits at your feet
            floor.position = SIMD3<Float>(0, -1.6, 0)
            content.add(floor)
            
            // 5. Create Ball
            let ball = createGolfBall()
            ball.name = "Ball"
            // Place ball slightly above the floor, 0.5m in front of you
            ball.position = SIMD3<Float>(0.0, -1.5, -0.5)
            content.add(ball)
            
            // 6. Subscribe to collisions
            collisionSubscription = content.subscribe(to: CollisionEvents.Began.self) { event in
                handleCollision(event: event)
            }
        }
    }
    
    func handleCollision(event: CollisionEvents.Began) {
        let entityA = event.entityA
        let entityB = event.entityB
        
        // Filter for Club vs Ball hits
        if (entityA.name == "Club" && entityB.name == "Ball") ||
           (entityB.name == "Club" && entityA.name == "Ball") {
            
            guard let sound = hitSound else { return }
            let ballEntity = (entityA.name == "Ball") ? entityA : entityB
            ballEntity.playAudio(sound)
        }
    }
    
    func setupClubPhysics(for entity: Entity) {
        // IMPORTANT: Generate collision shapes AFTER scaling
        // This ensures the physics hitbox matches the new large size
        entity.generateCollisionShapes(recursive: true)
        
        let clubMaterial = PhysicsMaterialResource.generate(
            staticFriction: 0.3, dynamicFriction: 0.3, restitution: 0.0
        )
        
        let physicsComponent = PhysicsBodyComponent(
            massProperties: .default,
            material: clubMaterial,
            mode: .kinematic // Moves with hand, unstoppable
        )
        entity.components.set(physicsComponent)
    }
    
    func createGolfBall() -> ModelEntity {
        let radius: Float = 0.0213 // 2.13cm
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: .white, isMetallic: false)
        let ball = ModelEntity(mesh: mesh, materials: [material])
        
        ball.generateCollisionShapes(recursive: false)
        
        // Bouncy material
        let ballPhysicsMat = PhysicsMaterialResource.generate(
            staticFriction: 0.2, dynamicFriction: 0.2, restitution: 0.8
        )
        
        var physics = PhysicsBodyComponent(
            massProperties: .init(mass: 0.045),
            material: ballPhysicsMat,
            mode: .dynamic
        )
        physics.isContinuousCollisionDetectionEnabled = true
        ball.components.set(physics)
        
        return ball
    }
    
    func createFloor() -> ModelEntity {
        let mesh = MeshResource.generatePlane(width: 10, depth: 10)
        // High transparency so you can see your real room
        let material = SimpleMaterial(color: .green.withAlphaComponent(0.2), isMetallic: false)
        
        let floor = ModelEntity(mesh: mesh, materials: [material])
        floor.generateCollisionShapes(recursive: false)
        floor.name = "Floor"
        floor.components.set(PhysicsBodyComponent(mode: .static))
        
        return floor
    }
    
    func convertDegreesToQuaternion(x: Float, y: Float, z: Float) -> simd_quatf {
        let angleX = x * .pi / 180
        let angleY = y * .pi / 180
        let angleZ = z * .pi / 180
        return simd_quatf(angle: angleX, axis: [1, 0, 0]) *
               simd_quatf(angle: angleY, axis: [0, 1, 0]) *
               simd_quatf(angle: angleZ, axis: [0, 0, 1])
    }
}
