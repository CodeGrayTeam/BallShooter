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
    var increaseY:Bool = false
    
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
    
    func updateYSpeedIfTooSmall() {
        if let dy = node.physicsBody?.velocity.dy {
            if (dy < 0.5 && dy > 0) || (dy == 0 && !increaseY) {
                let impulseY = -0.5 + dy
                print("Was: \(dy), Impulse: \(impulseY)")
                node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulseY))
            } else if (dy > -0.5 && dy < 0) || (dy == 0 && increaseY) {
                let impulseY = 0.5 - dy
                print("Was: \(dy), Impulse: \(impulseY)")
                node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulseY))
            }
            
            if dy == 0 {
                increaseY = !increaseY
            }
        }
    }
}
