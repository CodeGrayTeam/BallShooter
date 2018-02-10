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
    
    var node:SKNode!
    
    init (image: String, borderColour: SKColor, fillColour: SKColor, radius: CGFloat, xPosition: CGFloat, yPosition: CGFloat, speed:CGFloat, rotation:CGFloat, categoryBitMask: UInt32, contactTestBitMask: UInt32, collisionBitMask: UInt32, ballNum: Int) {
        self.radius = radius
        self.image = image
        self.fillColour = fillColour
        self.borderColour = borderColour
        self.speed = speed * 50
        self.rotation = rotation
        
        if image == "" {
            let tempNode = SKShapeNode(circleOfRadius: self.radius)
            tempNode.fillColor = self.fillColour
            tempNode.strokeColor = self.borderColour
            tempNode.position.x = xPosition
            tempNode.position.y = yPosition
            node = tempNode
            node.name = "\(ballNum)"
            node.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
        } else {
            node = SKSpriteNode(imageNamed: self.image)
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.frame.height / 2)
        }
        
        node.physicsBody?.isDynamic = true
        node.physicsBody?.usesPreciseCollisionDetection = true
        node.physicsBody?.categoryBitMask = categoryBitMask
        node.physicsBody?.contactTestBitMask = contactTestBitMask
        node.physicsBody?.collisionBitMask = collisionBitMask
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.friction = 0
        node.physicsBody?.mass = 10
        node.physicsBody?.linearDamping = 0
        node.position = CGPoint(x: xPosition, y: yPosition)
        
        calculateSpeeds()
    }
    
    func calculateSpeeds() {
        self.xSpeed = cos(self.rotation) * self.speed
        self.ySpeed = sin(self.rotation) * self.speed
    }
    
    func moveBall() {
        self.node.physicsBody?.velocity = CGVector(dx: self.xSpeed, dy: self.ySpeed)
    }
    
    func changeDirection(brick: Brick, contact: SKPhysicsContact) {

        let brickLeftX = brick.xPosition!
        let brickRightX = brick.xPosition! + brick.size!
        let brickTopY = brick.yPosition! + brick.size!
        let brickBottomY = brick.yPosition!
        let contactX = contact.contactPoint.x
        let contactY = contact.contactPoint.y
        
        print("BRICK: \(brick.brickNode.name ?? "No name"), T: \(brickTopY), B: \(brickBottomY), L: \(brickLeftX), R: \(brickRightX)")
        print("Contact point: \(contactX), \(contactY)")
        
        
        if contactY < brickBottomY {
            if contactX > brickLeftX + 0.1 && contactX < brickRightX - 0.1 {
                print("Should be bottom")
                self.changeYDirection(isTop: false)
            } else if contactX <= brickLeftX + 0.1 {
                print("Hit bottom left corner!")
                changeRotation(corner: "BL")
            } else if contactX >= brickRightX - 0.1 {
                print("Hit bottom right corner!")
                changeRotation(corner: "BR")
            }
        } else if contactY > brickTopY {
            if contactX > brickLeftX + 0.1 && contactX < brickRightX - 0.1 {
                print("Should be top")
                self.changeYDirection(isTop: true)
            } else if contactX <= brickLeftX + 0.1 {
                print("Hit top left corner!")
                changeRotation(corner: "TL")
            } else if contactX >= brickRightX - 0.1 {
                print("Hit top right corner!")
                changeRotation(corner: "TR")
            }
        } else if contactX < brickLeftX {
            if contactY > brickBottomY + 0.1 && contactY < brickTopY - 0.1 {
                print("Should be left")
                self.changeXDirection(isRight: false)
            } else if contactY <= brickBottomY + 0.1 {
                print("Hit bottom left corner!")
                changeRotation(corner: "BL")
            } else if contactY >= brickTopY - 0.1 {
                print("Hit top left corner!")
                changeRotation(corner: "TL")
            }
        } else if contactX > brickRightX {
            if contactY > brickBottomY + 0.1 && contactY < brickTopY - 0.1 {
                print("Should be right")
                self.changeXDirection(isRight: true)
            } else if contactY <= brickBottomY + 0.1 {
                print("Hit bottom right corner!")
                changeRotation(corner: "BR")
            } else if contactY >= brickTopY - 0.1 {
                print("Hit top right corner!")
                changeRotation(corner: "TR")
            }
        } else {
            print("Hit a bad corner!")
        }
        
        
    }
    
    //Corner can be one of the following: TL, TR, BT, BR (meaning top left, ...)
    func changeRotation(corner: String) {
        
        let twoPi:CGFloat = 2.0 * CGFloat.pi
        
        let absRotation:CGFloat =  (rotation + twoPi).truncatingRemainder(dividingBy: twoPi)
        
        switch corner {
        case "TL":
            if absRotation == (twoPi - (CGFloat.pi * 0.25)) {
                rotation! += CGFloat.pi
                calculateSpeeds()
            } else if absRotation > (twoPi - (CGFloat.pi * 0.25)) || absRotation <= (CGFloat.pi * 0.50) {
                changeXDirection(isRight: false)
            } else {
                changeYDirection(isTop: true)
            }
            break
        case "TR":
            if absRotation == (twoPi - (CGFloat.pi * 0.75)) {
                rotation! += CGFloat.pi
                calculateSpeeds()
            } else if absRotation > (twoPi - (CGFloat.pi * 0.75)) {
                changeYDirection(isTop: true)
            } else {
                changeXDirection(isRight: true)
            }
            break
        case "BL":
            if absRotation == (CGFloat.pi * 0.25) {
                rotation! += CGFloat.pi
                calculateSpeeds()
            } else if absRotation > (CGFloat.pi * 0.25) &&  absRotation <= CGFloat.pi {
                changeYDirection(isTop: false)
            } else {
                changeXDirection(isRight: true)
            }
            break
        case "BR":
            if absRotation == (CGFloat.pi * 0.75) {
                rotation! += CGFloat.pi
                calculateSpeeds()
            } else if absRotation > (CGFloat.pi * 0.75) {
                changeXDirection(isRight: true)
            } else {
                changeYDirection(isTop: false)
            }
            break
        default:
            print("Shouldn't be in here!")
            break
        }
    }
    
    func changeYDirection(isTop: Bool) {
        if (isTop == true && ySpeed < 0) || (isTop == false && ySpeed > 0) {
            self.ySpeed! *= -1
            rotation! *= -1
        }
    }
    
    func changeXDirection(isRight: Bool) {
        if (isRight == true && xSpeed < 0) || (isRight == false && xSpeed > 0) {
            self.xSpeed! *= -1
            
            rotation = acos(self.xSpeed! / self.speed)
            if ySpeed! < 0 {
                rotation! *= -1
            }
        }
    }
    
}
