//
//  GameScene.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-15.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import SpriteKit
import GameplayKit

let BallCategory:UInt32 = 0x1 << 0
let BrickCategory:UInt32 = 0x1 << 1
let WallCategory:UInt32 = 0x1 << 2
let KillBallCategory:UInt32 = 0x1 << 3
let PowerUpCategory:UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var viewController: GameViewController!
    var mode:String!
    
    static var screenHeight:CGFloat!
    static var screenWidth:CGFloat!
    static var brickSize:CGFloat!
    static var boardPosition:CGRect!
    var frames:Int!
    
    var starCountLabel:SKLabelNode!
    var starLabel:SKSpriteNode!
    var highscoreLabel:SKLabelNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var newPositionMarker:SKLabelNode!
    var numBallsLabel:SKLabelNode!
    var numBalls:Int = 1 {
        didSet {
            numBallsLabel.text = "x\(numBalls)"
        }
    }
    
    var ballShootTimer:Timer!
    var balls = [Ball]()
    var ballCount:Int!
    var maxBallCount:Int!
    
    var bricks = [Brick]()
    var bricksHit = [String]()
    
    var powerUps = [PowerUp]()
    var additionalBalls = 0
    
    var roof:SKShapeNode!
    var rightWall:SKShapeNode!
    var leftWall:SKShapeNode!
    var bottom:SKShapeNode!
    
    var launchLine = SKShapeNode()
    var launchLineX:CGFloat = 0.0
    var launchLineY:CGFloat = 0.0
    var ballX:CGFloat!
    var newBallX:CGFloat!
    var ballY:CGFloat!
    var ballRadius:CGFloat = 15.0
    
    var ballRotation:CGFloat!
    var firstBallEnded:Bool!
    
    enum GameState {
        case startUp, readyToPlay, playing, changeLevel, checkGameOver, endGame
    }
    var gameState:GameState!
    var gameOver:Bool!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
    
        gameState = .startUp
        ballCount = 0
        maxBallCount = 1
        frames = 0
        gameOver = false
        firstBallEnded = false
        ballRotation = 0.0
    
        initialize()
    }
    
    func initialize() {
        createBoard()
        ballX = GameScene.boardPosition.width / 2
        ballY = GameScene.boardPosition.origin.y + 2
        addWalls()
        addPowerUp()
        addBricks()
        moveObjectsDown()
    }
    
    func createBoard() {
        
        GameScene.screenHeight = self.frame.size.height
        GameScene.screenWidth = self.frame.size.width
        GameScene.brickSize = GameScene.screenWidth / 7
        
        let boardHeight = 9 * GameScene.brickSize
        
        //Remainder is broken into 3 parts, so that the bottom can be 1/3 and the top 2/3
        let remainderHeight = (GameScene.screenHeight - boardHeight) / 3
        
        GameScene.boardPosition = CGRect(x: 0, y: remainderHeight, width: GameScene.screenWidth, height: boardHeight)
        
        //Add highscore label
        let defaults = UserDefaults.standard
        highscoreLabel = SKLabelNode(text: "Best: \(defaults.object(forKey: "\(mode!)HighScore") as? Int ?? 1)")
        highscoreLabel.position = CGPoint(x: 100, y: GameScene.screenHeight - remainderHeight - 15)
        highscoreLabel.fontName = "AmericanTypewriter-Bold"
        highscoreLabel.fontSize = 30
        highscoreLabel.fontColor = UIColor.white
        self.addChild(highscoreLabel)
        
        //Add stars label
        starCountLabel = SKLabelNode(text: "\(defaults.object(forKey: "stars") as? Int ?? 0)")
        starCountLabel.position = CGPoint(x: GameScene.screenWidth - 80, y: GameScene.screenHeight - remainderHeight - 15)
        starCountLabel.fontName = "AmericanTypewriter-Bold"
        starCountLabel.fontSize = 30
        starCountLabel.fontColor = UIColor.white
        self.addChild(starCountLabel)
        
        starLabel = SKSpriteNode(imageNamed: "star.png")
        starLabel.position = CGPoint(x: GameScene.screenWidth - 130, y: GameScene.screenHeight - remainderHeight)
        self.addChild(starLabel)
        
        //Add score label
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: GameScene.screenWidth / 2, y: GameScene.screenHeight - remainderHeight - (remainderHeight / 3))
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = remainderHeight
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        score = 1
        
        //Add ball amount label
        numBallsLabel = SKLabelNode(text: "x1")
        numBallsLabel.position = CGPoint(x: GameScene.screenWidth / 2, y: remainderHeight - 20)
        numBallsLabel.fontName = "AmericanTypewriter-Bold"
        numBallsLabel.fontSize = 20
        numBallsLabel.fontColor = UIColor.white
        self.addChild(numBallsLabel)
        
        //Add new ball position label
        newPositionMarker = SKLabelNode(text: "x")
        newPositionMarker.position = CGPoint(x: GameScene.screenWidth / 2, y: remainderHeight + 5)
        newPositionMarker.fontName = "AmericanTypewriter-Bold"
        newPositionMarker.fontSize = 20
        newPositionMarker.fontColor = UIColor.white
        newPositionMarker.isHidden = true
        self.addChild(newPositionMarker)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState! == GameState.readyToPlay && children.contains(launchLine) {
            let x = launchLineX - ballX
            
            let ballLaunchY = ballY + ballRadius
            let absX = abs(x)
            
            let y = launchLineY - ballLaunchY
            
            if x < 0 {
                ballRotation = CGFloat.pi - atan(y/absX)
            } else {
                ballRotation = atan(y/absX)
            }
            
            //Only accept degrees from 15 - 165
            if ballRotation > CGFloat.pi / 18 && ballRotation < CGFloat.pi - (CGFloat.pi / 18) {
                removeBall(index: 0)
                ballCount = 0
                gameState = .playing
            }
            
            removeLaunchLine()
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState! == GameState.readyToPlay {
            if let touch = touches.first {
                moveLine(x: touch.location(in: view).x * 2, y: GameScene.screenHeight - touch.location(in: view).y * 2)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState! == GameState.readyToPlay {
            if let touch = touches.first {
                createLaunchLine(x: touch.location(in: view).x * 2, y: GameScene.screenHeight - touch.location(in: view).y * 2)
            } else {
                print("NIL TOUCH")
            }
        }
    }
    
    func createLaunchLine(x: CGFloat, y: CGFloat) {
        if !self.children.contains(launchLine) {
            
            launchLineX = x
            launchLineY = y
            
            var newX = x
            var newY = y
            
            let ballLaunchY = ballY + ballRadius
            
            let xSlope = x - ballX
            let ySlope = y - ballLaunchY
            let slope = ySlope / xSlope
            let b = ballLaunchY - slope * ballX
            
            
            var points = [CGPoint(x: ballX, y: ballLaunchY), CGPoint(x: x, y: y)]
            
            
            while (newX < GameScene.screenWidth && newX > 0) && (newY < GameScene.boardPosition.origin.y + GameScene.boardPosition.height && newY > GameScene.boardPosition.origin.y) {
                newX += xSlope
                newY += ySlope
                
                if newY > GameScene.boardPosition.origin.y + GameScene.boardPosition.height {
                    newY = GameScene.boardPosition.origin.y + GameScene.boardPosition.height
                    newX = (newY - b) / slope
                }
                
                points.append(CGPoint(x: newX, y: newY))
            }
                
            launchLine = SKShapeNode(points: &points, count: points.count)
            launchLine.lineWidth = 2
            launchLine.strokeColor = SKColor.white
            launchLine.fillColor = SKColor.white
            addChild(launchLine)
            
            let diffX = launchLineX - ballX
            let absX = abs(diffX)
            let diffY = launchLineY - ballLaunchY
            
            if diffX < 0 {
                ballRotation = CGFloat.pi - atan(diffY/absX)
            } else {
                ballRotation = atan(diffY/absX)
            }
            
            //Only accept degrees from 15 - 165
            if ballRotation > CGFloat.pi / 18 && ballRotation < CGFloat.pi - (CGFloat.pi / 18) {
                launchLine.isHidden = false
            } else {
                launchLine.isHidden = true
            }
        }
    }
    
    func removeLaunchLine() {
        if children.contains(launchLine) {
            launchLine.removeFromParent()
        }
    }
    
    func moveLine(x: CGFloat, y: CGFloat) {
        removeLaunchLine()
        createLaunchLine(x: x, y: y)
    }
    
//    func updateRotation() {
//        balls[0].rotation = ballRotation
//        balls[0].calculateSpeeds()
//    }
    
    func addBricks() {
        
        if mode == "bombDrop" && score % 2 != 0 {
            let randomPlacement = Int(arc4random_uniform(7))
            let brickValue = score * (3 + (score / 25))
            let brick = Brick(value: brickValue, placement: randomPlacement, size: GameScene.brickSize, categoryBitMask: BrickCategory, mode: mode)
            bricks.append(brick)
            addChild(brick.valueLabel)
            addChild(brick.brickNode)
        } else if mode != "bombDrop" {
            var maxNumberOfBlocks = ceil(Double(score) / 2.0 * 0.1 + 1.0)
            
            if maxNumberOfBlocks > 7 {
                maxNumberOfBlocks = 7
            }
            
            var scoreScale = Int(floor(Double(score) * 0.025))
            
            if scoreScale > 4 {
                scoreScale = 4
            }
            
            var numberOfBlocks = Int(arc4random_uniform(UInt32(maxNumberOfBlocks))) + 2 + scoreScale
            
            if numberOfBlocks > 7 {
                numberOfBlocks = 7
            }
            
            var placements = [Int]()
            
            for _ in 0...numberOfBlocks - 1 {
                
                var randomPlacement = Int(arc4random_uniform(7))
                while placements.contains(randomPlacement) {
                    randomPlacement = Int(arc4random_uniform(7))
                }
                placements.append(randomPlacement)
                
                let brick = Brick(value: score, placement: randomPlacement, size: GameScene.brickSize, categoryBitMask: BrickCategory, mode: mode)
                bricks.append(brick)
                addChild(brick.valueLabel)
                addChild(brick.brickNode)
            }
        }
    }
    
    func addPowerUp() {
        let randomPlacement = Int(arc4random_uniform(7))
        let ballPU = BallPU(placement: randomPlacement, categoryBitMask: PowerUpCategory, tileSize: GameScene.brickSize, mode: mode)
        
        powerUps.append(ballPU)
        self.addChild(ballPU.powerUpNode)
        
        //1 in 7 chance for star to spawn
        let isStar = Int(arc4random_uniform(7))
        if isStar == 3 {
            var starPlacement = randomPlacement
            while starPlacement == randomPlacement {
                starPlacement = Int(arc4random_uniform(7))
            }
            let starPU = StarPU(placement: starPlacement, categoryBitMask: PowerUpCategory, tileSize: GameScene.brickSize, mode: mode)
            powerUps.append(starPU)
            addChild(starPU.powerUpNode)
        }
    }
    
    func givePlayerStar() {
        let defaults = UserDefaults.standard
        let stars = defaults.object(forKey: "stars") as? Int ?? 0
        defaults.set(stars + 1, forKey: "stars")
        starCountLabel.text = "\(stars + 1)"
    }
    
    func addBall(shouldLaunch: Bool) {
        let ball = Ball(image: "", borderColour: .white, fillColour: .white, radius: ballRadius, xPosition: ballX, yPosition: ballY + ballRadius, speed: 10, rotation: ballRotation!, categoryBitMask: BallCategory, contactTestBitMask: BrickCategory | KillBallCategory | WallCategory | PowerUpCategory, collisionBitMask: WallCategory | BrickCategory, ballNum: self.ballCount)
        
        balls.append(ball)
        addChild(ball.node)
        
        ballCount! += 1
        numBalls = maxBallCount - ballCount + 1
        
        if numBalls == 1 {
            numBallsLabel.isHidden = true
        }
        
        if shouldLaunch {
            ball.launchBall()
        }
    }
    
    func addWalls() {
        var roofPoints = [CGPoint(x: 0, y: (GameScene.boardPosition.height + GameScene.boardPosition.origin.y)), CGPoint(x: GameScene.screenWidth, y: (GameScene.boardPosition.height + GameScene.boardPosition.origin.y))]
        var rightWallPoints = [CGPoint(x: GameScene.screenWidth + 1, y: 0), CGPoint(x: GameScene.screenWidth + 1, y: GameScene.screenHeight)]
        var leftWallPoints = [CGPoint(x: -1, y: 0), CGPoint(x: -1, y: GameScene.screenHeight)]
        var bottomPoints = [CGPoint(x: 0, y: GameScene.boardPosition.origin.y), CGPoint(x: GameScene.screenWidth, y: GameScene.boardPosition.origin.y)]

        
        roof = SKShapeNode(points: &roofPoints, count: roofPoints.count)
        roof.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: (GameScene.boardPosition.height + GameScene.boardPosition.origin.y)), to: CGPoint(x: GameScene.screenWidth, y: (GameScene.boardPosition.height + GameScene.boardPosition.origin.y)))
        roof.physicsBody?.isDynamic = false
        roof.physicsBody?.allowsRotation = false
        roof.physicsBody?.friction = 0.0
        roof.physicsBody?.affectedByGravity = false
        roof.physicsBody?.categoryBitMask = WallCategory
        
        rightWall = SKShapeNode(points: &rightWallPoints, count: rightWallPoints.count)
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: GameScene.screenWidth + 1, y: 0), to: CGPoint(x: GameScene.screenWidth + 1, y: GameScene.screenHeight))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.allowsRotation = false
        rightWall.physicsBody?.friction = 0.0
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.categoryBitMask = WallCategory
        
        leftWall = SKShapeNode(points: &leftWallPoints, count: leftWallPoints.count)
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -1, y: 0), to: CGPoint(x: -1, y: GameScene.screenHeight))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.allowsRotation = false
        leftWall.physicsBody?.friction = 0.0
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.categoryBitMask = WallCategory
        
        bottom = SKShapeNode(points: &bottomPoints, count: bottomPoints.count)
        bottom.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: GameScene.boardPosition.origin.y), to: CGPoint(x: GameScene.screenWidth, y: GameScene.boardPosition.origin.y))
        bottom.physicsBody?.isDynamic = false
        bottom.physicsBody?.allowsRotation = false
        bottom.physicsBody?.friction = 0.0
        bottom.physicsBody?.affectedByGravity = false
        bottom.physicsBody?.categoryBitMask = KillBallCategory
        
        if mode == "reversed" {
            bottom.strokeColor = SKColor.white
            roof.strokeColor = SKColor.init(red: (244/255), green: (75/255), blue: (66/255), alpha: 1.0)
            
            // Roof and bottom are switched
            bottom.physicsBody?.categoryBitMask = WallCategory
            roof.physicsBody?.categoryBitMask = KillBallCategory
        } else {
            bottom.strokeColor = SKColor.init(red: (244/255), green: (75/255), blue: (66/255), alpha: 1.0)
            roof.strokeColor = SKColor.white
        }
        
        addChild(roof)
        addChild(rightWall)
        addChild(leftWall)
        addChild(bottom)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        let countPoint = true
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == BallCategory {
            if let firstNode = firstBody.node as? SKShapeNode {
                switch secondBody.categoryBitMask {
                case BrickCategory:
                    if let secondNode = secondBody.node as? SKShapeNode, !bricksHit.contains("\(secondNode.name ?? ""), \(firstNode.name ?? "")") {
                        bricksHit.append("\(secondBody.node?.name ?? ""), \(firstBody.node?.name ?? "")")
                        ballDidHitBrick(brickNode: secondNode, ballNode: firstNode, decreasePoint: countPoint, contact: contact)
                    }
                case KillBallCategory:
                    killBall(ballNode: firstNode)
                case WallCategory:
                    hitWall(ballNode: firstNode)
                case PowerUpCategory:
                    if let secondNode = secondBody.node {
                        ballDidHitPowerUp(ballNode: firstNode, powerUpNode: secondNode)
                    }
                default:
                    print("Shouldn't hit here!")
                }
            }
        }
    }
    
    func hitWall(ballNode: SKShapeNode) {
        for i in (0...balls.count - 1).reversed() where balls[i].node == ballNode {
            balls[i].updateYSpeedIfTooSmall()
        }
    }
    
    func ballDidHitBrick(brickNode: SKShapeNode, ballNode: SKShapeNode, decreasePoint: Bool, contact: SKPhysicsContact) {
        var brick:Brick!
        
        var index = 0
        for j in (0...bricks.count - 1).reversed() {
            if bricks[j].brickNode == brickNode {
                brick = bricks[j]
                index = j
                //ball.changeDirection(brick: brick, contact: contact)
                brick.decreaseValue()
                break
            }
        }
        
        if brick.value == 0 {
            bricks.remove(at: index)
        }
        
        for i in (0...balls.count - 1).reversed() where balls[i].node == ballNode {
            balls[i].updateYSpeedIfTooSmall()
        }
    }
    
    func killBall(ballNode: SKShapeNode) {
        var index: Int = 0
        
        for i in (0...balls.count - 1).reversed() where balls[i].node == ballNode {
            index = i
            break
        }
        
        if !firstBallEnded {
            firstBallEnded = true
            newBallX = ballNode.position.x
            newPositionMarker.position.x = newBallX
            newPositionMarker.isHidden = false
        }
        
        //Remove ball if it hits the bottom
        removeBall(index: index)
        
        if balls.count == 0 {
            changeLevel()
        }
    }
    
    func ballDidHitPowerUp(ballNode:SKShapeNode, powerUpNode:SKNode) {
        var powerUp:PowerUp!
        var index = 0
        for pU in powerUps {
            if pU.powerUpNode == powerUpNode {
                powerUp = pU
                break
            }
            index += 1
        }
        
        if powerUp != nil {
            switch powerUp.type! {
            case .Ball:
                print("Hit ball")
                self.additionalBalls += 1
                powerUp.removeFromScreen()
                powerUps.remove(at: index)
                break
            case .Star:
                print("Hit star")
                givePlayerStar()
                powerUp.removeFromScreen()
                powerUps.remove(at: index)
                break
            }
        } else {
            print("NIL POWERUP")
        }
    }
    
    func removeBall(index: Int) {
        self.balls[index].node.removeFromParent()
        self.balls.remove(at: index)
    }
    
    func changeLevel() {
        gameState = .changeLevel
        firstBallEnded = false
        ballX = newBallX
        
        //Resets the ball counters and adds any adition balls gained from powerUps
        ballCount = 0
        maxBallCount! += additionalBalls
        additionalBalls = 0
        
        frames = 0
        score += 1
        addPowerUp()
        addBricks()
        moveObjectsDown()
        
        //Gives player a star if score is % 10
        if score % 10 == 0 {
            givePlayerStar()
        }
        
        checkHighScore()
    }
    
    func checkHighScore() {
        let defaults = UserDefaults.standard
        if score > defaults.object(forKey: "\(mode!)HighScore") as? Int ?? 0 {
            defaults.set(score, forKey: "\(mode!)HighScore")
            highscoreLabel.text = "Best: \(score)"
        }
    }
    
    func moveObjectsDown() {
        movePowerUpsDown()
        moveBricksDown()
    }
    
    func movePowerUpsDown() {
        if powerUps.count > 0 {
            for i in (0...powerUps.count - 1).reversed() {
                
                //If powerUp is off of board
                if !powerUps[i].moveDown() {
                    powerUps.remove(at: i)
                }
                
            }
        }
    }
    
    func moveBricksDown() {
        if bricks.count > 0 {
            for i in 0...bricks.count - 1 {
                bricks[i].moveDown()
                if bricks[i].row == 8 {
                    gameOver = true
                }
            }
        }
        
        setTimerForNextLevel()
    }
    
    func setTimerForNextLevel() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            //Show the number of balls
            self.numBallsLabel.position.x = self.ballX
            self.numBallsLabel.isHidden = false
            self.numBalls = self.maxBallCount
            
            //Removes newBallPosition marker
            self.newPositionMarker.isHidden = true
            self.addBall(shouldLaunch: false)
            
            self.gameState = .checkGameOver
        })
    }
    
    func endGame() {
        
        for child in self.children {
            child.removeFromParent()
        }
        
        bricks.removeAll()
        powerUps.removeAll()
        balls.removeAll()
        self.viewController.transitionToGameOver(score: score)
    }
    
    override func update(_ currentTime: TimeInterval) {
        switch gameState! {
        case .startUp:
            //Nothing as of yet
            break
        case .readyToPlay:
            //Nothing as of yet
            break
        case .playing:
            // Called before each frame is rendered
            // TODO: Change this to sequence or action????
            if frames % 5 == 0 && ballCount < maxBallCount && ballRotation! != 0.0 {
                addBall(shouldLaunch: true)
                frames = 0
            }
            
            frames! += 1

            break
        case .changeLevel:
            //Nothing as of yet
            break
        case .checkGameOver:
            
            if gameOver {
                gameState = .endGame
                endGame()
            } else {
                gameState = .readyToPlay
            }
            
            break
        case .endGame:
            break
        }
    }
    
    override func didFinishUpdate() {
        bricksHit.removeAll()
    }
}
