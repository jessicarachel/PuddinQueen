//
//  ContentView.swift
//  PuddingQueen
//
//  Created by Jessica Rachel on 20/05/23.
//

import SwiftUI
import SpriteKit
import AVFoundation

class StartScene: SKScene, AVAudioPlayerDelegate {
    
    var startButton: SKLabelNode?
    var backsoundStart: AVAudioPlayer?
    var isBackgroundSongPlayed = false
    var backsoundGame: AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene?.scaleMode = .aspectFill
        
        
        if backsoundStart == nil {
            if let backgroundSongURL = Bundle.main.url(forResource: "Itty Bitty", withExtension: "mp3") {
                do {
                    backsoundStart = try AVAudioPlayer(contentsOf: backgroundSongURL)
                    backsoundStart?.delegate = self
                    backsoundStart?.prepareToPlay()
                    backsoundStart?.numberOfLoops = -1
                    backsoundStart?.play()
                } catch {
                    print("Failed to load background song: \(error)")
                }
            }
        }
        startButton = childNode(withName: "startButton") as? SKLabelNode
        
        let scaleUpAction = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.5)
        let waitAction = SKAction.wait(forDuration: 0.5)
        let scaleSequence = SKAction.sequence([scaleUpAction, scaleDownAction, waitAction])
        let scaleForever = SKAction.repeatForever(scaleSequence)
    
        if let startButton = startButton {
            startButton.run(scaleForever)
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        if let backsoundStart = backsoundStart, backsoundStart.isPlaying {
            backsoundStart.stop()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let lokation = touch.location(in: self)
            let starNode = atPoint(lokation)
            
            if starNode.name == "startButton" {
                
                let game = GameScene(fileNamed: "GameScene")!
                game.backsoundGame = backsoundGame
                
                
                let transition = SKTransition.fade(withDuration: 1)
                self.view?.presentScene(game, transition: transition)
            }
        }
    }
}

struct ContentView: View {
    let startScene = StartScene(fileNamed: "StartScene")!
    
        
    
    var body: some View {
        SpriteView(scene: startScene)
            .ignoresSafeArea()
            .onAppear() {
                highScore = UserDefaults.standard.integer(forKey: "puddingQueenHighScore")
            }
    }
} 

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
