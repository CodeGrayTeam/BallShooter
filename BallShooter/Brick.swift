//
//  Brick.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-16.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import Foundation
import SpriteKit

class Brick {
    
    var borderColour:SKColor!
    var fillColour:SKColor!
    
    var xPosition:CGFloat!
    var yPosition:CGFloat!
    var size:CGFloat!
    var brickGap:CGFloat = 5.0
    
    var placement:Int!
    var row:Int!
    var mode:String!
    
    var valueLabel:SKLabelNode!
    var value:Int {
        didSet {
            changeColour()
            valueLabel.text = "\(value)"
        }
    }
    
    var brickNode:SKShapeNode!
    
    init(value: Int, placement: Int, size: CGFloat, categoryBitMask: UInt32, contactTestBitMask: UInt32, collisionBitMask: UInt32, mode: String) {
        self.mode = mode
        self.xPosition = (size * CGFloat(placement)) + brickGap
        
        if self.mode == "reversed" {
            self.yPosition = GameScene.boardPosition.origin.y + brickGap
        } else {
            self.yPosition = GameScene.boardPosition.height + GameScene.boardPosition.origin.y - (size) + brickGap
        }
        
        self.size = size - (brickGap * 2)
        self.placement = placement
        
        self.value = value
        self.row = 0
        
        createNodes(categoryBitMask: categoryBitMask, contactTestBitMask: contactTestBitMask, collisionBitMask: collisionBitMask)
        changeColour()
    }
    
    func createNodes(categoryBitMask: UInt32, contactTestBitMask: UInt32, collisionBitMask: UInt32) {
        valueLabel = SKLabelNode(text: "\(value)")
        valueLabel.position = CGPoint(x: self.xPosition + (size / 2), y: self.yPosition + (size / 2) - 15)
        valueLabel.fontName = "AmericanTypewriter-Bold"
        valueLabel.fontSize = 30
        valueLabel.fontColor = UIColor.black
        valueLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        
        let rect = CGRect(x: self.xPosition, y: self.yPosition, width: self.size, height: self.size)
        
        self.brickNode = SKShapeNode(rect: rect, cornerRadius: 1)
        self.brickNode.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        self.brickNode.physicsBody?.isDynamic = true
        self.brickNode.physicsBody?.categoryBitMask = categoryBitMask
        self.brickNode.physicsBody?.contactTestBitMask = contactTestBitMask
        self.brickNode.physicsBody?.collisionBitMask = collisionBitMask
        self.brickNode.name = "\(value) \(placement!)"
    }
    
    func changeColour() {
        let temp:CGFloat = CGFloat(self.value) * 10.0 / 256.0
        
        let green:CGFloat = 1.0 - min(temp, 1.0)
        let blue:CGFloat = max(0, min(temp, 1.0))
        let red:CGFloat = max(0, min(temp - 1, 1.0))
        
        self.brickNode.fillColor = SKColor.init(red: red, green: green, blue: blue, alpha: 1.0)
        self.brickNode.strokeColor = SKColor.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func moveDown() {
        self.row! += 1
        let dy = size + (brickGap * 2)
        
        let action:SKAction!
        
        if self.mode == "reversed" {
            self.yPosition! += dy
            action = SKAction.moveBy(x: 0, y: dy, duration: 0.5)
        } else  {
            self.yPosition! -= dy
            action = SKAction.moveBy(x: 0, y: -(dy), duration: 0.5)
        }
        
        self.brickNode.run(action)
        self.valueLabel.run(action)
    }
    
    func decreaseValue() {
        self.value -= 1
        
        if self.value == 0 {
            self.brickNode.removeFromParent()
            self.valueLabel.removeFromParent()
        }
    }
    
}
