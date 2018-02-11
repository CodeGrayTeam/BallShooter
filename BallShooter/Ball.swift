//
//  Ball.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-15.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import Foundation
import SpriteKit

class Ball {
    
    var image:String!
    var borderColour:SKColor!
    var fillColour:SKColor!
    
    var radius:CGFloat!
    
    var xSpeed:CGFloat! 
    var ySpeed:CGFloat!
    var speed:CGFloat!
    
    var rotation:CGFloat!
    var increaseY:Bool = true
    
    var node:SKNode!
    
    init (image: String, borderColour: SKColor, fillColour: SKColor, radius: CGFloat, xPosition: CGFloat, yPosition: CGFloat, speed:CGFloat, rotation:CGFloat, categoryBitMask: UInt32, contactTestBitMask: UInt32, collisionBitMask: UInt32, ballNum: Int) {
        self.radius = radius
        self.image = image
        self.fillColour = fillColour
        self.borderColour = borderColour
        self.speed = speed
        self.rotation = rotation
        
        if image == "" {
            let tempNode = SKShapeNode(circleOfRadius: radius)
            tempNode.fillColor = fillColour
            tempNode.strokeColor = borderColour
            tempNode.position.x = xPosition
            tempNode.position.y = yPosition
            node = tempNode
            node.name = "\(ballNum)"
            node.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
        } else {
            node = SKSpriteNode(imageNamed: self.image)
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.frame.height / 2)
        }
        node.position = CGPoint(x: xPosition, y: yPosition)
        
        node.physicsBody?.usesPreciseCollisionDetection = true
        node.physicsBody?.categoryBitMask = categoryBitMask
        node.physicsBody?.contactTestBitMask = contactTestBitMask
        node.physicsBody?.collisionBitMask = collisionBitMask
        node.physicsBody?.friction = 0
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
        node.physicsBody?.restitution = 1
        node.physicsBody?.mass = 0.009
        node.physicsBody?.allowsRotation = false
    }
    
    func launchBall() {
        xSpeed = cos(rotation) * speed
        ySpeed = sin(rotation) * speed
        node.physicsBody?.applyImpulse(CGVector(dx: xSpeed, dy: ySpeed))
    }
    
    /// Description: If a ball gets set to 0 dy after hitting a block or top or bottom
    /// this will give it some y velocity
    func updateYSpeedIfTooSmall() {
        if let dy = node.physicsBody?.velocity.dy {
            if (dy < 0.8 && dy > 0) {
                let impulseY = -0.8 + dy
                node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulseY))
            } else if (dy > -0.8 && dy < 0) {
                let impulseY = 0.8 - dy
                node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulseY))
            } else if dy == 0 {
                updateYIfZero()
            }
        }
    }
    
    func updateYIfZero() {
        if let dy = node.physicsBody?.velocity.dy, dy == 0 {
            if increaseY {
                node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0.8))
            } else {
                node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -0.8))
            }
            increaseY = !increaseY
        }
    }
    
    /// Description: If a ball gets set to 0 dx after hitting a wall
    /// this will give it some x velocity
    ///
    /// - Parameter isRightWall: Boolean to say if right or left wall
    func updateXSpeedAfterHittingWall(isRightWall: Bool) {
        if let dx = node.physicsBody?.velocity.dx {
            switch isRightWall {
            case true:
                if dx < 0.8 && dx >= 0 {
                    let impulseX = -0.8 + dx
                    node.physicsBody?.applyImpulse(CGVector(dx: impulseX, dy: 0))
                }
            case false:
                if dx > -0.8 && dx <= 0 {
                    let impulseX = 0.8 - dx
                    node.physicsBody?.applyImpulse(CGVector(dx: impulseX, dy: 0))
                }
            }
        }
    }
}
