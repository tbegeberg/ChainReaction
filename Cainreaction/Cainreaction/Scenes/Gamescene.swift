//
//  Gamescene.swift
//  Cainreaction
//
//  Created by TørK on 07/12/2017.
//  Copyright © 2017 Tørk Egeberg. All rights reserved.
//

import Foundation
import SpriteKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Cat: UInt32 = 0b1
    static let Bomb: UInt32 = 0b10
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var catPosition = [String:CGPoint]()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)

        multipleSprite(amount: 10)
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Cat != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bomb != 0)) {
            if let cat = firstBody.node as? SKSpriteNode, let
                bomb = secondBody.node as? SKSpriteNode {
                bombDidCollideWithCat(bomb: bomb, cat: cat)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        let bomb = SKSpriteNode(imageNamed: "explosion")
        bomb.position = touchLocation
        bomb.size = CGSize(width: bomb.size.width/2, height: bomb.size.height/2)
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: bomb.frame.size.width/2)
        bomb.physicsBody?.isDynamic = true
        bomb.physicsBody?.categoryBitMask = PhysicsCategory.Bomb
        bomb.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        bomb.physicsBody?.collisionBitMask = PhysicsCategory.None
        bomb.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(bomb)
        let actionMove = SKAction.move(to: touchLocation, duration: 0.5)
        let actionMoveDone = SKAction.removeFromParent()
        bomb.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func createCat() -> SKSpriteNode {
        let sprite = SKSpriteNode(imageNamed: "cat")
        let actualX = random(min: sprite.size.width/2, max: self.size.width - sprite.size.width/2)
        let actualY = random(min: sprite.size.height/2, max: self.size.height - sprite.size.height/2)
        sprite.position = CGPoint(x: actualX, y: actualY)
        sprite.size = CGSize(width: sprite.size.width/2, height: sprite.size.height/2)
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.frame.size.width/2)
        sprite.physicsBody?.restitution = 0
        sprite.physicsBody?.affectedByGravity = true
        sprite.physicsBody?.mass = 200
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.Cat
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Bomb
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
        sprite.physicsBody?.isDynamic = true
        return sprite
    }

    func multipleSprite(amount: Int) {
        var i: Int = 0
        while i < amount {
            i += 1
            let sprite = createCat()
            sprite.name = "CAT \(i)"
            if let name = sprite.name {
                self.catPosition[name] = sprite.position
            }
            print(self.catPosition)
            self.addChild(sprite)
        }
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func bombDidCollideWithCat(bomb: SKSpriteNode, cat: SKSpriteNode) {
        print("Hit")
        cat.removeFromParent()
    }
    
}

extension CGPoint {
    func distanceFromCGPoint(point:CGPoint)->CGFloat{
        return sqrt(pow(self.x - point.x,2) + pow(self.y - point.y,2))
    }
}

