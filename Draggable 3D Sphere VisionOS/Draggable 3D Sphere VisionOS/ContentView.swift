//
//  ContentView.swift
//  Draggable 3D Sphere VisionOS
//
//  Created by Steinhauer, Jan on 2/11/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var sphere = ModelEntity()
    
    var body: some View {
        RealityView { content in
            let sphereMesh = MeshResource.generateSphere(radius: 0.4)
            let material = SimpleMaterial(color: .green, isMetallic: false)
            sphere = ModelEntity(mesh: sphereMesh, materials: [material])
            
            sphere.components.set(InputTargetComponent(allowedInputTypes: .indirect))
            sphere.generateCollisionShapes(recursive: true)
            sphere.components.set(GroundingShadowComponent(castsShadow: true))

            sphere.position = SIMD3<Float>(0.0, 1.5, -2.0)

            content.add(sphere)
            
        }
        .gesture(
            DragGesture()
                .targetedToEntity(sphere)
                .onChanged({ value in
                    sphere.position = value.convert(value.location3D, from: .local, to: sphere.parent!)
                })
        )

    }
}

#Preview("Immersive Style", immersionStyle: .automatic, body: {
        ContentView()
})
