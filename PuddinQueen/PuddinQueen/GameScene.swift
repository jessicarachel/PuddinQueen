//
//  GameScene.swift
//  PuddinQueen
//
//  Created by Jessica Rachel on 19/05/23.
//

import SpriteKit

class GameScene: SKScene {
    var character: CharacterNode!
    
    override func didMove(to view: SKView) {
        // Set the anchor point to the center of the scene
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Create and configure the character node
        character = CharacterNode(imageNamed: "playerPng")
        character.position = CGPoint(x: 0, y: -300)  // Update the position based on the anchor point
        
        // Adjust the size of the character
        let newSize = CGSize(width: 100, height: 100)  // Set the desired size
        character.size = newSize
        
        character.physicsBody = SKPhysicsBody(rectangleOf: newSize)  // Adjust physics body size as well
        character.physicsBody?.affectedByGravity = false
        
        addChild(character)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if the tap occurred on the character
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let tappedNodes = nodes(at: touchLocation)
        if tappedNodes.contains(character) {
            character.jump()
        }
    }
}
