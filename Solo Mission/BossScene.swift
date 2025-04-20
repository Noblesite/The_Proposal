//
//  BossScene.swift
//  Solo Mission
//
//  Created by Jonathon Poe on 11/14/16.
//  Copyright © 2016 Noblesite. All rights reserved.
//

import Foundation
import SpriteKit

class BossScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let bossLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    let bulletSound = SKAction.playSoundFileNamed("bulletSoundEffect.wav", waitForCompletion: false)
    let explostionSound = SKAction.playSoundFileNamed("explosionSoundEffect.wav", waitForCompletion: false)
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let tapToStartLabel2 = SKLabelNode(fontNamed: "The Bold Font")
    
    var bossHealthPoints = 100
    
    var bossLevel = 1
    
    var bossPostionX = CGFloat()
    
    var bossCount = 2
    
    enum gameState{
        case preGame //when the game state is before the game
        case inGame //when the game state is during the game
        case afterGame ///when the game has ended
        case gameWin
        
    }
    
    var currentGameState = gameState.preGame
    
    
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32  = 0b100 //4
        static let Boss : UInt32 = 0b101 // 5
        static let Health : UInt32 = 0b0110 // 6
    }
    
    
    func random() ->CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min:CGFloat, max:CGFloat) ->CGFloat {
        return random() * (max - min) + min
    }
    
    
    
    
    
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
      
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
            
            let background = SKSpriteNode(imageNamed: "background2")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2,
                                          y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
            
        }
        
        player.setScale(0.5)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        player.name = "Player"
        self.addChild(player)
        
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: 0 - scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: \(livesNumber)"
        livesLabel.fontSize = 70
        livesLabel.color = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        bossLabel.text = "Boss: \(bossHealthPoints)"
        bossLabel.fontSize = 70
        bossLabel.color = SKColor.white
        bossLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bossLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + bossLabel.frame.size.height)
        bossLabel.zPosition = 100
        self.addChild(bossLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        let moveOnToScreenActionBottom = SKAction.moveTo(y: self.size.height*0.10, duration: 0.3)
        
        bossLabel.run(moveOnToScreenAction)
        scoreLabel.run(moveOnToScreenActionBottom)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "Level 2!"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        tapToStartLabel2.text = "Press to Begin"
        tapToStartLabel2.fontSize = 100
        tapToStartLabel2.fontColor = SKColor.white
        tapToStartLabel2.zPosition = 1
        tapToStartLabel2.position = CGPoint(x: self.size.width/2, y: self.size.height*0.4)
        tapToStartLabel2.alpha = 0
        self.addChild(tapToStartLabel2)

        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        tapToStartLabel2.run(fadeInAction)
        
        
        
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
       // let amountToMoveBoss = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background"){
            background, stop in
            
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
                
                
                if background.position.y < -self.size.height{
                    background.position.y += self.size.height*2
                }
            }
            
        }
      
        
        
        
        
    }
    
    
    
    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeIn(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        tapToStartLabel2.run(deleteSequence)
        
        let moveShipOnToScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOnToScreenAction, startLevelAction])
        player.run(startGameSequence)
        spawnBoss()
        
        
    }
    
    
    
    
    func loseALife(){
        
        var currentPlayer = SKNode()
        
        self.enumerateChildNodes(withName: "Player"){
            player, stop in
            currentPlayer = player
        }
        
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let playerFadeDown = SKAction.fadeOut(withDuration: 0.3)
        let playerFadeUp = SKAction.fadeIn(withDuration: 0.3)
        let fadeSequence = SKAction.sequence([playerFadeDown, playerFadeUp, playerFadeDown, playerFadeUp, playerFadeDown, playerFadeUp])
        
        livesLabel.run(scaleSequence)
        currentPlayer.run(fadeSequence)
        if livesNumber == 0{
            if livesNumber < 0 {
                livesNumber = 0
            }
            runGameOver()
        }
        
    }
    
    
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        scoreLabel.run(scaleSequence)
        
        if gameScore == 60 || gameScore == 70 || gameScore == 80 || gameScore == 90 {
            startNewLevel()
        }
    }
    
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        
        self.removeAllActions()
        
        
        self.enumerateChildNodes(withName: "bossMissile"){
            Boss, stop in
            Boss.removeAllActions()
        }

        self.enumerateChildNodes(withName: "Boss1"){
            Boss, stop in
            Boss.removeAllActions()
        }
        
        
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    func changeScene(){
        
        
        
        let special:Bool = UserDefaults().bool(forKey: "use_Special")
        if (special != true){
            
            if currentGameState == gameState.afterGame {
            let sceneToMoveTo = GameOverScene(size: self.size)
            sceneToMoveTo.scaleMode = self.scaleMode
            let myTransition = SKTransition.fade(withDuration: 0.5)
            self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            if currentGameState == gameState.gameWin{
            //let sceneToMoveTo = GameWinScene(size: self.size)
            let sceneToMoveTo = GameSceneTwo(size: self.size)
            sceneToMoveTo.scaleMode = self.scaleMode
            let myTransition = SKTransition.fade(withDuration: 0.5)
            self.view!.presentScene(sceneToMoveTo, transition: myTransition)

            }
            
        }else{
            let sceneToMoveTo = SpecialScene(size: self.size)
            sceneToMoveTo.scaleMode = self.scaleMode
            let myTransition = SKTransition.fade(withDuration: 0.5)
            self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            
        }
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
            
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            // if the player has hit the enemy
            
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            loseALife()
            body2.node?.removeFromParent()
            
        
            
        }
       //if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height{
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < gameArea.maxY{
            //if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy{
            //if the bullet has hit the enemy
            
            addScore()
            
            if body2.node != nil && body1.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Boss && (body2.node?.position.y)! < self.size.height{
            
            
            bossHealth()
            
            if body2.node != nil && body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            body1.node?.removeFromParent()
        }

        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Health{
            // if the player has hit the enemy
            
            AddALife()
            body2.node?.removeFromParent()
            
            
            
            
        }
        
        
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explostion = SKSpriteNode(imageNamed: "explosition")
        explostion.position = spawnPosition
        explostion.zPosition = 3
        explostion.setScale(0)
        self.addChild(explostion)
        
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explostionSound, scaleIn, fadeOut, delete])
        
        explostion.run(explosionSequence)
        
        
        
        
    }
    
    
    
    
    func startNewLevel(){
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1.0
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        case 5: levelDuration = 0.35
        case 6: levelDuration = 0.2
        case 7: levelDuration = 0.1
        default:
            levelDuration = 0.5
            print("Cannot find level info")
            
        }
        
        let spwan = SKAction.run(spawnEnemy)
        let waitToSpwan = SKAction.wait(forDuration:levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpwan, spwan])
        let spwanForever = SKAction.repeatForever(spawnSequence)
        self.run(spwanForever, withKey: "spawningEnemies")
        
    }
    
    
    
    func fireBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet" //ref name
        bullet.setScale(0.55)
        bullet.position.y = player.position.y * 1.45
        bullet.position.x = player.position.x
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    
    func spawnEnemy(){
        
        var playerPosition = CGPoint()
        
        self.enumerateChildNodes(withName: "Player"){
            player, stop in
         playerPosition = player.position
            
        }
        
        let randomXStart = random(min:gameArea.minX , max:gameArea.maxX)
        let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "Enemy2")
        enemy.name = "Enemy"
        enemy.setScale(1.8)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
       // let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let moveEnemy = SKAction.move(to: playerPosition, duration: 2.5)
        let deleteEnemy = SKAction.removeFromParent()
        //let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame{
            startGame()
        }
            
        else if currentGameState == gameState.inGame {
            fireBullet()
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
            }
            if player.position.x >= gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x <= gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
            
        }
    }
    
    func spawnBoss(){
    
        bossHealthPoints = 100
        
        let startPoint = CGPoint(x: self.size.width/2 , y: self.size.height * 1.2)
        let endPoint = CGPoint(x: self.size.width/2 , y: self.size.height*0.9)
        
        let boss = SKSpriteNode(imageNamed: "Boss")
        boss.name = "Boss1"
        boss.setScale(2)
        boss.position = startPoint
        boss.zPosition = 3
        boss.physicsBody = SKPhysicsBody(rectangleOf: boss.size)
        boss.physicsBody!.affectedByGravity = false
        boss.physicsBody!.categoryBitMask = PhysicsCategories.Boss
        boss.physicsBody!.collisionBitMask = PhysicsCategories.None
        boss.physicsBody!.contactTestBitMask = PhysicsCategories.Bullet
        self.addChild(boss)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 0.5)
        let enemySequence = SKAction.sequence([moveEnemy])
        
        
        if currentGameState == gameState.inGame{
        boss.run(enemySequence)
            
            
        }
    }
    
    func bossHealth(){
        
        bossHealthPoints -= 1
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        bossLabel.run(scaleSequence)
        
        
        if bossHealthPoints >= 90 {
            bossLevel = 1
            //randomBossPostion()
        }
        if bossHealthPoints == 80 {
            bossLevel = 2
            spawnLife()
        }
        if bossHealthPoints == 70 {
            bossLevel = 4
        }
        if bossHealthPoints == 60 {
            bossLevel = 5
            
        }
        
        if bossHealthPoints == 30 {
            spawnLife()
            
        }

        if bossHealthPoints <= 0{
            
            gameScore = gameScore + 100
            
            bossCount -= 1
            
            if self.action(forKey: "spawningMissiles") != nil{
                self.removeAction(forKey: "spawningMissiles")
            }
            self.enumerateChildNodes(withName: "bossMissile"){
                bossMissile, stop in
                bossMissile.removeAllActions()
                bossMissile.removeFromParent()
            
            }
                self.enumerateChildNodes(withName: "Boss1"){
                Boss, stop in
                let position = CGPoint(x: Boss.position.x , y: Boss.position.y)
                    self.spawnBossExplosion(spawnPosition: position)
                    
                Boss.removeAllActions()
                Boss.removeFromParent()
                print("Boss Removed calld")
                
                
                if self.bossCount <= 0{
                self.runGameWin()
                }else{
                    self.spawnBossTwo()
                }
                
            }
        }
        
        if self.action(forKey: "spawningMissiles") != nil{
            self.removeAction(forKey: "spawningMissiles")
        }
        
        
    
        
        var levelDuration = TimeInterval()
        
        switch bossLevel {
        case 1: levelDuration = 1.0
        case 2: levelDuration = 0.9
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.7
        case 5: levelDuration = 0.6
        default:
            levelDuration = 0.4
            print("Cannot find level info")
            
        }
        if bossCount >= 2{
        let spwan = SKAction.run(spawnBossMissile)
        let waitToSpwan = SKAction.wait(forDuration:levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpwan, spwan])
        let spwanForever = SKAction.repeatForever(spawnSequence)
        let bossMove = SKAction.run(randomBossPostion)
        let bossMoveWait = SKAction.wait(forDuration: 0.5)
        let bossMoveSequence = SKAction.sequence([bossMoveWait, bossMove])
        
            self.enumerateChildNodes(withName: "Boss1"){
                Boss, stop in
                Boss.run(bossMoveSequence)
            }

        
            self.run(spwanForever, withKey: "spawningMissiles")

        bossLabel.text = "Boss: \(bossHealthPoints)"
        }else{
            let spwan = SKAction.run(spawnBossMissile)
            let waitToSpwan = SKAction.wait(forDuration:levelDuration)
            let spwanMissleSequence = SKAction.sequence([spwan,spwan])
            let spawnSequence = SKAction.sequence([waitToSpwan, spwanMissleSequence])
            let bossMove = SKAction.run(randomBossPostion)
            let bossMoveWait = SKAction.wait(forDuration: 0.5)
            let bossMoveSequence = SKAction.sequence([bossMoveWait, bossMove])
            let spwanForever = SKAction.repeatForever(spawnSequence)
            
            self.run(spwanForever, withKey: "spawningMissiles")
            
            self.enumerateChildNodes(withName: "Boss1"){
                Boss, stop in
                    Boss.run(bossMoveSequence)
            }
            
            bossLabel.text = "Boss: \(bossHealthPoints)"
            
        }
        
        
    }
 
    
    
    
    func spawnBossMissile(){
        
        /*if currentGameState == gameState.inGame{
            randomBossPostion()
        }*/

        
        var bossPossition = CGPoint()
        
        self.enumerateChildNodes(withName: "Boss1"){
            Boss, stop in
            bossPossition = Boss.position
        }
        
        if bossPossition != nil{
        
        //let randomXStart = random(min: bossPossition.minX , max: bossPossition.maxX)
        let randomXStart = random(min: bossPossition.x * 0.6, max:bossPossition.x * 1.4)
        let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: bossPossition.y)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let bossMissile = SKSpriteNode(imageNamed: "bossMissile")
        bossMissile.name = "bossMissile"
        bossMissile.setScale(1.25)
        bossMissile.position = startPoint
        bossMissile.zPosition = 2
        bossMissile.physicsBody = SKPhysicsBody(rectangleOf: bossMissile.size)
        bossMissile.physicsBody!.affectedByGravity = false
        bossMissile.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        bossMissile.physicsBody!.collisionBitMask = PhysicsCategories.None
        bossMissile.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(bossMissile)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        
        if currentGameState == gameState.inGame{
            bossMissile.run(enemySequence)
            //randomBossPostion()
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        bossMissile.zRotation = amountToRotate
        
        }
        
    }

    
    func spawnBossExplosion(spawnPosition: CGPoint){
        
        let explostion = SKSpriteNode(imageNamed: "bossExplosion")
        explostion.position = spawnPosition
        explostion.zPosition = 3
        explostion.setScale(0)
        self.addChild(explostion)
        
        
        let scaleIn = SKAction.scale(to: 12, duration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.6)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explostionSound, scaleIn, fadeOut, scaleIn, fadeOut, scaleIn, fadeOut, delete])
        
        explostion.run(explosionSequence)
        print("spwanBossExplosion called")
        
        
        
        
    }

    
    func randomBossPostion(){
        
        if self.action(forKey: "moveBoss") != nil{
            self.removeAction(forKey: "moveBoss")
        }

        
        print("Random Boss Postion called")
        self.enumerateChildNodes(withName: "Boss1"){
            boss, stop in

        let randomX = self.random(min:self.gameArea.minX , max:self.gameArea.maxX)
        let bossMove = SKAction.moveTo(x: randomX, duration: 0.6)
        let moveSequence = SKAction.sequence([bossMove])
        //let moveForever = SKAction.repeatForever(moveSequence)
        boss.run(moveSequence, withKey: "moveBoss")
    
        }
    }
    
    func spawnBossTwo(){
        
        
        
        bossHealthPoints = 100
        bossLevel = 0
        
        let startPoint = CGPoint(x: self.size.width/2 , y: self.size.height * 1.2)
        let endPoint = CGPoint(x: self.size.width/2 , y: self.size.height*0.9)
        
        let boss = SKSpriteNode(imageNamed: "boss2")
        boss.name = "Boss1"
        boss.setScale(2)
        boss.position = startPoint
        boss.zPosition = 3
        boss.physicsBody = SKPhysicsBody(rectangleOf: boss.size)
        boss.physicsBody!.affectedByGravity = false
        boss.physicsBody!.categoryBitMask = PhysicsCategories.Boss
        boss.physicsBody!.collisionBitMask = PhysicsCategories.None
        boss.physicsBody!.contactTestBitMask = PhysicsCategories.Bullet
        self.addChild(boss)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2.5)
        let enemySequence = SKAction.sequence([moveEnemy])
        
        
        if currentGameState == gameState.inGame{
            boss.run(enemySequence)
            
            
        }
    }
 
    func runGameWin(){
        
        currentGameState = gameState.gameWin
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "bossMissile"){
            Boss, stop in
            Boss.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Boss1"){
            Boss, stop in
            Boss.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeFromParent()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
    }

    
    
    func AddALife(){
        
        var currentPlayer = SKNode()
        
        self.enumerateChildNodes(withName: "Player"){
            player, stop in
            currentPlayer = player
        }
        
        
        livesNumber += 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let playerTurnWhite = SKAction.colorize(with: SKColor.white, colorBlendFactor: 0.8, duration: 1.5)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let playerFadeDown = SKAction.fadeOut(withDuration: 0.3)
        let playerFadeUp = SKAction.fadeIn(withDuration: 0.3)
        let fadeSequence = SKAction.sequence([playerFadeDown, playerFadeUp, playerTurnWhite, playerFadeDown, playerFadeUp, playerTurnWhite ,playerFadeDown, playerFadeUp, playerTurnWhite])
        
        livesLabel.run(scaleSequence)
        currentPlayer.run(fadeSequence)
        
        
        
    }
    
    
    
    func spawnLife(){
        
       var bossTemp = CGPoint()
        
        self.enumerateChildNodes(withName: "Boss1"){
            boss, stop in
            bossTemp = boss.position
        }
        
        //let randomXStart = random(min:gameArea.minX , max:gameArea.maxX)
        let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
        
        let startPoint = CGPoint(x: bossTemp.x , y: bossTemp.y)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let life = SKSpriteNode(imageNamed: "HealthOrb")
        life.name = "LifePoint"
        life.setScale(0.2)
        life.position = startPoint
        life.zPosition = 2
        life.physicsBody = SKPhysicsBody(rectangleOf: life.size)
        life.physicsBody!.affectedByGravity = false
        life.physicsBody!.categoryBitMask = PhysicsCategories.Health
        life.physicsBody!.collisionBitMask = PhysicsCategories.None
        life.physicsBody!.contactTestBitMask = PhysicsCategories.Player
        self.addChild(life)
        
        let moveLife = SKAction.move(to: endPoint, duration: 3.8)
        let deleteLife = SKAction.removeFromParent()
        
        let enemySequence = SKAction.sequence([moveLife, deleteLife])
        
        if currentGameState == gameState.inGame{
            life.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        life.zRotation = amountToRotate
        
        
        
    }

    
    
    
}
