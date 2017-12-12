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
    static let Cat: UInt32 = 1
    static let Bomb: UInt32 = 2
    static let Wall: UInt32 = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.Wall
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
            (secondBody.categoryBitMask & PhysicsCategory.Cat != 0)) {
            if let cat = firstBody.node as? SKSpriteNode, let
                bomb = secondBody.node as? SKSpriteNode {
                self.children.filter({ (aNode) -> Bool in
                    guard let newCat = aNode as? CatNode else {
                        return false
                    }
                    guard cat.position.distanceFromCGPoint(point: newCat.position) < 50 else {
                        return false
                    }
                    return true
                }).forEach({ (explodingCat) in
                    //explodingCat.removeFromParent()
                })
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
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        bomb.physicsBody?.isDynamic = true
        bomb.physicsBody?.categoryBitMask = PhysicsCategory.Bomb
        bomb.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        bomb.physicsBody?.collisionBitMask = PhysicsCategory.None
        bomb.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(bomb)
        let actionMove = SKAction.move(to: touchLocation, duration: 0.5)
        let actionMoveDone = SKAction.removeFromParent()
        bomb.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        for cat in self.children {
            cat.physicsBody?.applyImpulse(CGVector(dx: random(min: -10, max: 10), dy: random(min: -10, max: 10)))
        }
        
    }
    
    func createCat() -> SKSpriteNode {
        let cat = CatNode()
        let actualX = random(min: cat.size.width/2, max: self.size.width - cat.size.width/2)
        let actualY = random(min: cat.size.height/2, max: self.size.height - cat.size.height/2)
        cat.position = CGPoint(x: actualX, y: actualY)
        return cat
    }

    func multipleSprite(amount: Int) {
        var i: Int = 0
        while i < amount {
            let sprite = createCat()
            i += 1
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

class CatNode: SKSpriteNode {
    
    convenience init() {
        self.init(imageNamed: "cat")
        self.size = CGSize(width: self.size.width/2, height: self.size.height/2)
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.frame.size.width/2)
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.friction = 1.0
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Cat
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bomb
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        self.physicsBody?.collisionBitMask = PhysicsCategory.Wall
        self.physicsBody?.isDynamic = true
        self.name = "cat"

    }
}



