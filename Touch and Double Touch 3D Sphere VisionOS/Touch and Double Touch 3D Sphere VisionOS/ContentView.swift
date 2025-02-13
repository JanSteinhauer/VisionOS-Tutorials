//
//  ContentView.swift
//  Touch and Double Touch 3D Sphere VisionOS
//
//  Created by Steinhauer, Jan on 2/13/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State private var sphere = ModelEntity()
    @State private var tapped = false
    @State private var doubleTapped = false
    
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
        .highPriorityGesture(
            TapGesture(count: 2)
                .targetedToEntity(sphere)
                .onEnded { _ in
                    doubleTapped.toggle()
                    sphere.scale = .init(repeating: doubleTapped ? 0.5 : 1)
                    print("double click")
                }
        )
        
        .gesture(
            TapGesture(count: 1)
                .targetedToEntity(sphere)
                .onEnded { _ in
                    tapped.toggle()
                    sphere.model?.materials = [
                        SimpleMaterial(color: tapped ? .blue : .green, isMetallic: false)
                    ]
                    print("single click")
                }
        )
    }
}
