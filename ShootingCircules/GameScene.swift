//
//  GameScene.swift
//  ShootingCircules
//
//  Created by Jesper Linne on 2016-01-04.
//  Copyright (c) 2016 Jesper Linné. All rights reserved.
//

import SpriteKit
import CoreData

struct PhysicsCategory {
    static let Enemy :UInt32 = 0x1 << 0
    static let ShootingBall : UInt32 = 0x1 << 1
    static let PlayerBall : UInt32 = 0x1 << 2
}

var backgroundColorCustom = UIColor.blackColor()

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let moc = DataController().managedObjectContext
    
    var PlayerBall = SKSpriteNode(imageNamed: "Globe-48")
    
    var EnemyTimer = NSTimer()
    
    var hits = 0
    var gamestarted = false
    
    var tapToBeginLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var scoreLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")
    var highScoreLabel = SKLabelNode(fontNamed: "STHeitiJ-Medium")

    var fadingAnimation = SKAction()
    
    var score = 0
    var highscore = 0
    
    
    

    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        getData()
        saveData()
        
        self.backgroundColor = backgroundColorCustom
        self.physicsWorld.contactDelegate = self
        
        var highscoreDefault = NSUserDefaults.standardUserDefaults()
        if highscoreDefault.valueForKey("Highscore") !=  nil {
            
            highscore = highscoreDefault.valueForKey("Highscore") as! Int
            highScoreLabel.text = "Highscore = \(highscore)"
            
            saveData()
            
            let entity = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: moc) as! Person
            
            entity.setValue(highscore, forKey: "highscoreDataController")
            
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context\(error)")
            }
            
        }
        
        
        
        tapToBeginLabel.text = "Tap to begin"
        tapToBeginLabel.fontSize = 34
        tapToBeginLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)     // texten hamnar i mitten
        tapToBeginLabel.fontColor = UIColor.whiteColor()
        tapToBeginLabel.zPosition = 2.0 // så den kommer över bollen
        self.addChild(tapToBeginLabel)
        
        fadingAnimation = SKAction.sequence([SKAction.fadeInWithDuration(1.0), SKAction.fadeOutWithDuration(1.0)])
        tapToBeginLabel.runAction(SKAction.repeatActionForever(fadingAnimation)) //Gör att den alltid blinkar
        
        
        highScoreLabel.text = "Highscore =  \(highscore)"
        highScoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
        highScoreLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        addChild(highScoreLabel)
        
        scoreLabel.alpha = 0
        scoreLabel.fontSize = 35
        scoreLabel.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 1.3)
        scoreLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        scoreLabel.text = "\(score)"
        self.addChild(scoreLabel)
        
        
        
        
        
        PlayerBall.size = CGSize(width: 225, height: 225) // storleken när träffad två gånger
        PlayerBall.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        PlayerBall.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        PlayerBall.colorBlendFactor = 1.0
        
        PlayerBall.zPosition = 1.0
        
        PlayerBall.physicsBody = SKPhysicsBody(circleOfRadius: PlayerBall.size.width / 2)
        PlayerBall.physicsBody?.categoryBitMask = PhysicsCategory.PlayerBall
        PlayerBall.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
        PlayerBall.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        PlayerBall.physicsBody?.affectedByGravity = false
        PlayerBall.physicsBody?.dynamic = false
        PlayerBall.name = "MainBall"
        
        
        self.addChild(PlayerBall)
        

    }
    
    func saveData() {
        
        let entity = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: moc) as! Person
        
        entity.setValue(highscore, forKey: "highscoreDataController")
        
        do {
            try moc.save()
        } catch {
            fatalError("Failure to save context\(error)")
        }
        
    }
    
    
    func getData() {
        
    let personFetch = NSFetchRequest(entityName: "Person")
        
        do {
            let fetchedPerson = try moc.executeFetchRequest(personFetch) as! [Person]
            
            highScoreLabel.text = "Highscore =  \(fetchedPerson)"
            
        } catch {
            
            highscore = 0
            
            let entity = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: moc) as! Person
            
            entity.setValue(highscore, forKey: "highscoreDataController")
            
            do {
                try moc.save()
            } catch {
                fatalError("Failure to save context\(error)")
            }
            
            
            //fatalError("BAD THINGS HAPPEN\(error)")
        }
        
    }
    
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node != nil && contact.bodyB.node != nil {
            let firstBody = contact.bodyA.node as! SKSpriteNode
            let secondBody = contact.bodyB.node as! SKSpriteNode
            
            if ((firstBody.name == "Enemy") && (secondBody.name == "SmallBall"))  {
                
                collisionBullet(firstBody, SmallBall: secondBody)
          
                }
                else if ((firstBody.name == "SmallBall") && (secondBody.name == "Enemy")){
                
                collisionBullet(secondBody, SmallBall: firstBody)
             
            }
            else if ((firstBody.name == "MainBall") && (secondBody.name == "Enemy")){
                
                collisionmain(secondBody)
            }
            else if((firstBody.name == "Enemy") && (secondBody.name == "MainBall")) {
                collisionmain(firstBody)
        
                    }
            }
    }
    
    
    


    func collisionmain(Enemy : SKSpriteNode) {
        if hits < 2 {
            PlayerBall.runAction(SKAction.scaleBy(1.5, duration: 0.4))
            Enemy.physicsBody?.affectedByGravity = true
            Enemy.removeAllActions()
            PlayerBall.runAction(SKAction.sequence([SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.1), SKAction.colorizeWithColor(SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.1)]))
            
            hits++
            Enemy.removeFromParent() //De förstör sig själva
        }
        
        else {
            
            lostGame()
            
            Enemy.removeFromParent()
            EnemyTimer.invalidate() //Stannar timern när if satsen är klar
            gamestarted = false
            
            scoreLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            tapToBeginLabel.runAction(SKAction.fadeInWithDuration(1.0))
            tapToBeginLabel.runAction(SKAction.repeatActionForever(fadingAnimation))
            highScoreLabel.runAction(SKAction.fadeInWithDuration(0.2))
            
            
            //sparar ner highscore
            if score > highscore {
                let highscoreDefault = NSUserDefaults.standardUserDefaults()
                highscore = score
                highscoreDefault.setInteger(highscore, forKey: "HighScore")
                highScoreLabel.text = "Highscore = \(highscore)"
                highscoreDefault.synchronize()
                
            
            }
            
            
            
        }
    }
    

    func lostGame() {
        
        let alertController = UIAlertController(title: "Lose!", message: "You lost, you have to wait for your health to recover", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        //presentViewController(alertController, animated: true, completion: nil)

    }
    
    
    
    func collisionBullet(Enemy : SKSpriteNode, SmallBall : SKSpriteNode) {
        Enemy.physicsBody?.dynamic = true
        
        Enemy.physicsBody?.affectedByGravity = true
        
        Enemy.physicsBody?.mass = 5.0
        SmallBall.physicsBody?.mass = 5.0
        
        Enemy.removeAllActions()
        SmallBall.removeAllActions()
        Enemy.physicsBody?.contactTestBitMask = 0
        Enemy.physicsBody?.collisionBitMask = 0
        Enemy.name = nil
        
        score++
        scoreLabel.text = "\(score)"
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        
        if gamestarted == false {
            EnemyTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("Enemies"), userInfo: nil, repeats: true)
            gamestarted = true
            PlayerBall.runAction(SKAction.scaleTo(0.44, duration: 0.2))
            hits = 0
            
            
            tapToBeginLabel.removeAllActions()
            tapToBeginLabel.runAction(SKAction.fadeOutWithDuration(0.2))
            highScoreLabel.runAction(SKAction.fadeOutWithDuration(0.2))

            
            scoreLabel.runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.fadeInWithDuration(1.0)]))
            
            score = 0
            scoreLabel.text = "\(score)"
            
            
        } else {
            
        
        
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            let SmallBall = SKSpriteNode(imageNamed: "RoundBall")
            SmallBall.zPosition = -1.0
            SmallBall.size = CGSize(width: 15, height: 15)
            SmallBall.position = PlayerBall.position
            SmallBall.physicsBody = SKPhysicsBody(circleOfRadius: SmallBall.size.width / 2)
            SmallBall.physicsBody?.affectedByGravity = true
            
            
            SmallBall.physicsBody?.categoryBitMask = PhysicsCategory.ShootingBall
            SmallBall.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
            SmallBall.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
            SmallBall.name = "SmallBall"
            SmallBall.physicsBody?.dynamic = true
            SmallBall.physicsBody?.affectedByGravity = true
            
            
            var dx = CGFloat(location.x - PlayerBall.position.x)
            var dy = CGFloat(location.y - PlayerBall.position.y)
            
            let magnitude = sqrt(dx * dx + dy * dy)
            
            dx /= magnitude
            dy /= magnitude
            
            self.addChild(SmallBall)
            
            let vector = CGVectorMake(16.0 * dx, 16.0 * dy)
            
            SmallBall.physicsBody?.applyImpulse(vector)
            
            }
        }
    }
    
    func Enemies() {
        
        let Enemy = SKSpriteNode(imageNamed: "Sci-Fi-48") // Image
        Enemy.size = CGSize(width: 50, height: 50)
      //  Enemy.color = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
      //  Enemy.colorBlendFactor = 1.0
        
        //// physics
        Enemy.physicsBody = SKPhysicsBody(circleOfRadius: Enemy.size.width / 2)
        Enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        Enemy.physicsBody?.contactTestBitMask = PhysicsCategory.ShootingBall | PhysicsCategory.PlayerBall //There is a contact if they hit each other
        Enemy.physicsBody?.collisionBitMask = PhysicsCategory.ShootingBall | PhysicsCategory.PlayerBall //Collision if they hit each other
        Enemy.physicsBody?.affectedByGravity = false //no gravity affected
        Enemy.physicsBody?.dynamic = true
        Enemy.name = "Enemy"
        
        
        
        
        
        
        
        let RandomPosNumber = arc4random() % 4
        
        switch RandomPosNumber {
        case 0:
            Enemy.position.x = 0 //random value from the left
            var PositionY = arc4random_uniform(UInt32(frame.size.height))
            
            Enemy.position.y = CGFloat(PositionY)
            
            self.addChild(Enemy)
            break
        case 1:
            
            if score > 5 {
            Enemy.position.y = 0 // random value from upperside
            
            var PositionY = arc4random_uniform(UInt32(frame.size.width))
            
            Enemy.position.x = CGFloat(PositionY)
            
            self.addChild(Enemy)
            }
            
            break
        case 2:
            
            if score > 10 {
            Enemy.position.y = frame.size.height // random value from downside
            
            var PositionY = arc4random_uniform(UInt32(frame.size.width))
            
            Enemy.position.x = CGFloat(PositionY)
            
            self.addChild(Enemy)
            }
            
            break
        case 3:
            
            if score > 15 {
            Enemy.position.x = frame.size.width //random value on right side
            
            var PositionY = arc4random_uniform(UInt32(frame.size.height))
            
            Enemy.position.y = CGFloat(PositionY)
            
            self.addChild(Enemy)
            
            }
            
            break
        default:
            
            break
        }
        
        Enemy.runAction(SKAction.moveTo(PlayerBall.position, duration: 3))
        
    }
    
    
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
