//
//  ContentView.swift
//  3DSpinAnimation
//
//  Created by Steinhauer, Jan on 02.04.25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State var startTime = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let timeInterval = context.date.timeIntervalSince(startTime)
            let angle = Angle.degrees((timeInterval * 30).truncatingRemainder(dividingBy: 360))
            
        
        
        VStack {
            Model3D(named: "Road_Pillar")
                .scaleEffect(15.0)
                .rotation3DEffect(angle, axis: (x: 0, y: 1, z: 0))
        }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
