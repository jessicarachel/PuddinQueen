//
//  ContentView.swift
//  PuddinQueen
//
//  Created by Jessica Rachel on 19/05/23.
//

import SwiftUI
import SpriteKit

struct GameSceneView: View {
    var scene: SKScene {
           let scene = GameScene(size: UIScreen.main.bounds.size)
           scene.scaleMode = .aspectFill
           return scene
       }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

struct ContentView: View {
    var body: some View {
        GameSceneView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
