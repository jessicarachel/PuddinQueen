//
//  GameScene.swift
//  PuddingQueen
//
//  Created by Jessica Rachel on 20/05/23.
//

import Foundation
import SpriteKit
import SwiftUI
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    var jumpSoundPlayer: AVAudioPlayer?
    var pushSoundPlayer: AVAudioPlayer?
    var backsoundGame: AVAudioPlayer?
    
    @Published var score = 0{
            didSet {
               if score > highScore {
                   highScore = score
               }
           }
        }
    
    var player: SKSpriteNode!
    let playerJumpForce = 375
    let playerDeathForce = (120.0, 50.0)
    var puddingGround: SKSpriteNode!
    let pudding = SKSpriteNode(imageNamed: "pudding")
    var background: SKSpriteNode!
    
    let jumpSoundAction = SKAction.playSoundFileNamed("Jump Sound Effect.mp3", waitForCompletion: false)
    let pushSoundAction = SKAction.playSoundFileNamed("Cartoon punch sound effect.mp3", waitForCompletion: false)
    
    var lastPuddingYPosition = 0.0
    
    var puddingCheck = true
    var swipeEnabled = true

    var scoreLabel: SKLabelNode? = nil
    var highScoreLabel: SKLabelNode? = nil
    
    let cam = SKCameraNode()
    var currentPudding = Pudding()
    var lastUpdateTime: TimeInterval!
    var canJump = true
    var rayNode: SKSpriteNode!
    var gameOver = false
    var playerFall = false
    
    enum bitmasks: UInt32 {
        case player = 0x1
        case pudding = 0x2
        case rayBottom = 0x4
        case rayHorizontal = 0x5
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        scoreLabel = childNode(withName: "//scoreLabel") as? SKLabelNode
        highScoreLabel = childNode(withName: "//highScore") as? SKLabelNode
        
        puddingGround = childNode(withName: "puddingGround") as? SKSpriteNode
        puddingGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: puddingGround.size.width, height: puddingGround.size.height-30))
        puddingGround.physicsBody?.isDynamic = true
        puddingGround.physicsBody?.restitution = 0
        puddingGround.physicsBody?.allowsRotation = false
        puddingGround.physicsBody?.affectedByGravity = false
        puddingGround.physicsBody?.categoryBitMask = bitmasks.pudding.rawValue
        puddingGround.physicsBody?.collisionBitMask = 0
        puddingGround.physicsBody?.contactTestBitMask = 0
        
        player = childNode(withName: "player") as? SKSpriteNode
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2 - 12.5)
        player.physicsBody?.mass = 0.46
        player.physicsBody?.isDynamic = true
        player.physicsBody?.restitution = 0
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        player.physicsBody?.collisionBitMask = bitmasks.pudding.rawValue
        player.physicsBody?.contactTestBitMask = 0
        lastPuddingYPosition = player.position.y
        makePudding()
        
        if let jumpSoundURL = Bundle.main.url(forResource: "Jump Sound Effect", withExtension: "mp3") {
                    do {
                        jumpSoundPlayer = try AVAudioPlayer(contentsOf: jumpSoundURL)
                        jumpSoundPlayer?.prepareToPlay()
                    } catch {
                        print("Failed to load jump sound effect: \(error)")
                    }
                }
        
        if let pushSoundURL = Bundle.main.url(forResource: "Cartoon punch sound effect", withExtension: "mp3") {
                    do {
                        pushSoundPlayer = try AVAudioPlayer(contentsOf: pushSoundURL)
                        pushSoundPlayer?.prepareToPlay()
                    } catch {
                        print("Failed to load push sound effect: \(error)")
                    }
                }
        
        if let backsoundGameURL = Bundle.main.url(forResource: "Vibe Mountain", withExtension: "mp3") {
                   do {
                       backsoundGame = try AVAudioPlayer(contentsOf: backsoundGameURL)
                       backsoundGame?.prepareToPlay()
                       backsoundGame?.numberOfLoops = -1
                       backsoundGame?.play()
                       
                   } catch {
                       print("Failed to load jump sound effect: \(error)")
                   }
               }
        
        cam.setScale(1)
        cam.position.x = player.position.x
        camera = cam
        
        rayNode = SKSpriteNode()
        addChild(rayNode)
    }
    
    override func willMove(from view: SKView) {
           super.willMove(from: view)
           
           if let backsoundGame = backsoundGame, backsoundGame.isPlaying {
               backsoundGame.stop()
           }
       }
    
    override func didSimulatePhysics() {
        let rayStartPos = CGPoint(x: player.position.x, y: player.position.y - player.size.height/2.5)
        let rayEndPos = CGPoint(x: rayStartPos.x, y: rayStartPos.y - 25)
        
        let ray = SKPhysicsBody(edgeFrom: rayStartPos, to: rayEndPos)
        ray.categoryBitMask = bitmasks.rayBottom.rawValue
        ray.contactTestBitMask = bitmasks.pudding.rawValue
        ray.collisionBitMask = 0
        rayNode.physicsBody = ray
    
        let rayH = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width - 10, height: player.size.height - 20), center: player.position)
        rayH.categoryBitMask = bitmasks.rayHorizontal.rawValue
        rayH.contactTestBitMask = bitmasks.pudding.rawValue
        rayH.collisionBitMask = 0
        physicsBody = rayH
        
        if playerFall {
            if player.physicsBody!.velocity.dx > 0.0 {
                player.physicsBody?.velocity.dx -= 2
            }
        }
    }
    
    func addScore() {
        currentPudding.stoppedMoving = true
        if currentPudding.stoppedMoving == true {
            player.texture = SKTexture(imageNamed: "queenStart")
        }
        canJump = true
        if !gameOver {
            score += 1 // Increase the score
            updateScoreLabel() // Update the score label
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bitmaskA = contact.bodyA.categoryBitMask
        let bitmaskB = contact.bodyB.categoryBitMask
        
        if (bitmaskA == bitmasks.rayBottom.rawValue && bitmaskB == bitmasks.pudding.rawValue) ||
            (bitmaskA == bitmasks.pudding.rawValue && bitmaskB == bitmasks.rayBottom.rawValue) {
            
            let puddingObj = (bitmaskA == bitmasks.pudding.rawValue) ? contact.bodyA : contact.bodyB
            
            if puddingObj.node?.name != "puddingGround" {
                if let puddingNode = puddingObj.node as? Pudding, puddingNode == currentPudding {
                    addScore()
                }
            }
        }
        
        if (bitmaskA == bitmasks.rayHorizontal.rawValue && bitmaskB == bitmasks.pudding.rawValue) ||
            (bitmaskA == bitmasks.pudding.rawValue && bitmaskB == bitmasks.rayHorizontal.rawValue) {
            
            let puddingObj = (bitmaskA == bitmasks.pudding.rawValue) ? contact.bodyA : contact.bodyB
            
            if puddingObj.node?.name != "puddingGround" {
                if let puddingNode = puddingObj.node as? Pudding, puddingNode == currentPudding {
                    currentPudding.stoppedMoving = true
                    gameOver = true
                    canJump = false
                    pushSoundPlayer?.play()
                    
                    UserDefaults.standard.set(highScore, forKey: "puddingQueenHighScore")
                    
                    let puddingScript = puddingObj.node as? Pudding
                    player.physicsBody?.applyImpulse(CGVector(dx: playerDeathForce.0 * puddingScript!.direction, dy: playerDeathForce.1))
                    
                    let waitAction = SKAction.wait(forDuration: 0.5)
                    let stopAction = SKAction.run {
                        self.playerFall = true
                        self.player.physicsBody?.affectedByGravity = false
                        self.player.physicsBody?.velocity.dx /= 16
                        self.player.physicsBody?.velocity.dy = -100
                        self.player.texture = SKTexture(imageNamed: "queenFall")
           
                        
                        self.cam.setScale(1.75)
                    }
                    let waitAction2 = SKAction.wait(forDuration: 1)
                    player.run(SKAction.sequence([waitAction, stopAction, waitAction2])) {
                        let game = StartScene(fileNamed: "StartScene")!
                        let transition = SKTransition.fade(withDuration: 3)
                        
                        self.view?.presentScene(game, transition: transition)
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        cam.position = CGPoint(x: player.position.x, y: player.position.y )
        
        if lastUpdateTime == nil {
            lastUpdateTime = currentTime - 0.02
        }
        else if currentTime - lastUpdateTime == 1.0 {
            lastUpdateTime = currentTime - 0.02
        }
        
        let deltaTime = Double(currentTime - lastUpdateTime)
        
        if !currentPudding.stoppedMoving {
            currentPudding.moveHorizontal(deltaTime: deltaTime, scene: self)
        }
        else if !gameOver {
            makePudding()
        }
        
        lastUpdateTime = currentTime
        if let scoreLabel = scoreLabel {
               scoreLabel.position = CGPoint(x: cam.position.x, y: cam.position.y + 200)
           }
        if let highScoreLabel = highScoreLabel {
               highScoreLabel.position = CGPoint(x: cam.position.x, y: cam.position.y + 150)
            
           }
        background = childNode(withName: "bg") as? SKSpriteNode
        background.position.y = player.position.y
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard swipeEnabled else { return }
        super.touchesMoved(touches, with: event)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canJump {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: playerJumpForce))
            player.texture = SKTexture(imageNamed: "queenJump")
            canJump = false
            
            
            // Play the jump sound effect
            jumpSoundPlayer?.play()
            
            
        }
    }
    
    func makePudding() {
        let pudding = Pudding(imageNamed: "pudding")
        pudding.gameScene = self
        
        pudding.zPosition = 0
        pudding.setScale(0.3)
        pudding.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pudding.size.width-50, height: pudding.size.height-30))
        pudding.physicsBody?.allowsRotation = false
        pudding.physicsBody?.affectedByGravity = false
        pudding.physicsBody?.isDynamic = true
        pudding.physicsBody?.categoryBitMask = bitmasks.pudding.rawValue
        pudding.physicsBody?.collisionBitMask = 0
        pudding.physicsBody?.contactTestBitMask = 0
        
//        if want to random
//        let randomSpeed = Double.random(in: 125...300)
//        pudding.moveSpeed = randomSpeed

        let speedIncrement = 8.0 // Adjust this value as desired
        let increasedSpeed = pudding.moveSpeed + (Double(score) * speedIncrement)
           pudding.moveSpeed = increasedSpeed
        
        let randomBool = Bool.random()  // Randomly choose left or right direction
        let randomDirection = randomBool ? 1.0 : -1.0
        
        let startXPos = frame.size.width/2.0 * randomDirection + pudding.size.width * randomDirection
        pudding.position = CGPoint(x: startXPos, y: lastPuddingYPosition)
        lastPuddingYPosition += (pudding.size.height - 50)
        addChild(pudding)
        pudding.direction = -randomDirection
        
        currentPudding = pudding
        
    }
    
    func updateScoreLabel() {
        scoreLabel?.text = "\(score)"
        highScoreLabel?.text = "High Score: \(highScore)"
    }
}

class GameData: ObservableObject{
    
}
