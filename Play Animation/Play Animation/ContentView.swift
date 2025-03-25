//
//  ContentView.swift
//  Play Animation
//
//  Created by Steinhauer, Jan on 25.03.25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
        RealityView { content in
            if let butterflyEntity = try? await Entity(named: "Butterfly") {
                butterflyEntity.position = [0, 1.5, -0.2]
                content.add(butterflyEntity)
                
                for animation in butterflyEntity.availableAnimations {
                    butterflyEntity.playAnimation(animation.repeat())
                }
            }
            
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
