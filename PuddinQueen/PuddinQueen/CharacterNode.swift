//
//  CharacterNode.swift
//  PuddinQueen
//
//  Created by Jessica Rachel on 19/05/23.

import SpriteKit

class CharacterNode: SKSpriteNode {
    private var hasJumped = false
    private var originalPosition: CGPoint!
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        originalPosition = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func jump() {
        // Check if the character has already jumped
        guard !hasJumped else { return }
        
        // Set hasJumped to true to prevent further jumps
        hasJumped = true
        
        // Reset the character's position to the original position
        position = originalPosition
        
        // Calculate the jump height (adjust this value as needed)
        let jumpHeight: CGFloat = 200
        
        // Perform a sequence of actions for the jump
        let jumpUpAction = SKAction.moveBy(x: 0, y: jumpHeight, duration: 0.2)
        let jumpDownAction = SKAction.moveBy(x: 0, y: -jumpHeight, duration: 0.2)
        let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])
        
        run(jumpSequence) {
            // Reset hasJumped flag after the jump sequence completes
            self.hasJumped = false
        }
    }
}
