//
//  ContentView.swift
//  3D Word VisionOS
//
//  Created by Steinhauer, Jan on 15.04.25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
      var body: some View {
          RealityView { content in
              let anchor = AnchorEntity(world: [-0.5, 1.5, -1])
              
              let textMesh = MeshResource.generateText(
                  "hello world!",
                  extrusionDepth: 0.02,
                  font: UIFont(name: "SnellRoundhand", size: 0.2)!
              )
              
              let textEntity = ModelEntity(
                  mesh: textMesh,
                  materials: [SimpleMaterial(color: .red, isMetallic: false)]
              )
              
              anchor.addChild(textEntity)
              
              content.add(anchor)
          }
      }
  }

