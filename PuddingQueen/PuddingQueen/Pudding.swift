//
//  Pudding.swift
//  PuddingQueen
//
//  Created by Jessica Rachel on 22/05/23.
//

import SpriteKit

class Pudding: SKSpriteNode {
    var gameScene: GameScene?
    var direction = 1.0
    var moveSpeed = 150.0
    var stoppedMoving = false
    
    func moveHorizontal(deltaTime: Double, scene: GameScene) {
        if stoppedMoving { return  }
        
        if direction > 0 && position.x < 0 || direction < 0 && position.x > 0 {
            position.x += (direction * moveSpeed * deltaTime)
        }
        else {
            gameScene?.addScore()
        }
    }
}
