//
//  GameScene.swift
//  SpaceWar
//
//  Created by  Toropov Oleksandr on 26.02.2024.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let spaceShipCategory: UInt32 = 0x1 << 0
    let asteroidCategory: UInt32 = 0x1 << 1
    
    var spaceShip: SKSpriteNode!
    var score = 0
    var scoreLabel: SKLabelNode!
    var spaceBackground: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.8)
        
        scene?.size = UIScreen.main.bounds.size
        
        spaceBackground = SKSpriteNode(imageNamed: "SpaceBackground")
        addChild(spaceBackground)
        
        spaceShip = SKSpriteNode(imageNamed: "SpaceShip")
        spaceShip.size = CGSize(width: 100, height: 100)
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        
        addChild(spaceShip)
        
        
        let asteroidCreation = SKAction.run {
            let asteroid = self.createAsteroid()
            self.addChild(asteroid)
            asteroid.zPosition = 2
        }
        let asteroidCreationDelay = SKAction.wait(forDuration: 1.0, withRange: 0.5)
        let asteroidSequence = SKAction.sequence([asteroidCreation, asteroidCreationDelay])
        let asteroidRun = SKAction.repeatForever(asteroidSequence)
        
        run(asteroidRun)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width / scoreLabel.frame.width , y: 300)
        
        addChild(scoreLabel)
        
        spaceBackground.zPosition = 0
        spaceShip.zPosition = 1
        scoreLabel.zPosition = 3
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        
        let distance = calculateDistance(from: spaceShip.position, to: touchLocation)
        let speed: CGFloat = 500
        let time = calculateTime(distance: distance, speed: speed)
        
        let moveAction = SKAction.move(to: touchLocation, duration: time)
        moveAction.timingMode = SKActionTimingMode.easeInEaseOut
        spaceShip.run(moveAction)
        
        let backgroundMoveAction = SKAction.move(to: CGPoint(x: -touchLocation.x / 100, y: -touchLocation.y /  100), duration: time)
        spaceBackground.run(backgroundMoveAction)
    }
    
    func calculateDistance(from pointA: CGPoint, to pointB: CGPoint) -> CGFloat {
        sqrt(pow(pointB.x - pointA.x, 2) + pow(pointB.y - pointA.y, 2))
    }
    
    func calculateTime(distance: CGFloat, speed: CGFloat) -> TimeInterval {
        TimeInterval(distance / speed)
    }
    
    func createAsteroid() -> SKSpriteNode {
        let asteroid = SKSpriteNode(imageNamed: "Asteroid")
        asteroid.size = CGSize(width: 50, height: 50)
        
        let randomScale = CGFloat.random(in: 0.5...2)
        asteroid.xScale = randomScale
        asteroid.yScale = randomScale
        
        asteroid.position.x = CGFloat(Int.random(in: -Int(frame.size.width) / 2...Int(frame.size.width) / 2))
        asteroid.position.y = (frame.size.height + asteroid.size.height) / 2
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.name = "asteroid"
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory | asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
        
        let asteroisSpeedX: CGFloat = 100.0
        asteroid.physicsBody?.angularVelocity = CGFloat(Int.random(in: -1...2)) * 3
        asteroid.physicsBody?.velocity.dx = CGFloat(Int.random(in: -1...2)) * asteroisSpeedX
        
        return asteroid
    }
    
    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "asteroid") { asteroid, stop in
            let screenHeight = UIScreen.main.bounds.height
            if asteroid.position.y < -screenHeight / 2 {
                asteroid.removeFromParent()
                
                self.score += 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask  == asteroidCategory {
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
    }
}
