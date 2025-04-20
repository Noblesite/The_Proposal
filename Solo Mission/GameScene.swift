//
//  GameScene.swift
//  Solo Mission
//
//  Created by Jonathon Poe on 11/10/16.
//  Copyright © 2016 Noblesite. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0
var livesNumber = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var enemyOneSpawnRate = 0
    
    var enemyTwoSpawnRate = 0
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    let bulletSound = SKAction.playSoundFileNamed("bulletSoundEffect.wav", waitForCompletion: false)
    let explostionSound = SKAction.playSoundFileNamed("explosionSoundEffect.wav", waitForCompletion: false)
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    
    enum gameState{
        case preGame //when the game state is before the game
        case inGame //when the game state is during the game
        case afterGame ///when the game has ended
        case moving
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
        
        gameScore = 0
        
        livesNumber = 5
        
        enemyTwoSpawnRate = 0
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
            
        let background = SKSpriteNode(imageNamed: "background")
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
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: \(livesNumber)"
        livesLabel.fontSize = 70
        livesLabel.color = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "Press to Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
      
        
        
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
        
        let moveShipOnToScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startAndSetEnemySpawn)
        let startGameSequence = SKAction.sequence([moveShipOnToScreenAction, startLevelAction])
        player.run(startGameSequence)
        
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
        
        
        // JP change for debug
        if gameScore >= 100 {
            currentGameState = gameState.moving
            prepToMoveToNextLevel()
            
            
        
        }else if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startAndSetEnemySpawn()
        }
        
        if gameScore == 25 || gameScore == 40 || gameScore == 60{
            startAndSetEnemyTwoSpawn()
        }
        
        if gameScore == 35 || gameScore == 60{
            spawnLife()
        }

    }
    
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        self.enumerateChildNodes(withName: "EnemyTwo"){
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
    
            let sceneToMoveTo = GameOverScene(size: self.size)
            sceneToMoveTo.scaleMode = self.scaleMode
            let myTransition = SKTransition.fade(withDuration: 0.5)
            self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            
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
    
    
    
    
    func startAndSetEnemySpawn(){
        
        enemyOneSpawnRate += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch enemyOneSpawnRate {
        case 1: levelDuration = 1.5
        case 2: levelDuration = 1.4
        case 3: levelDuration = 1.3
        case 4: levelDuration = 1.2
        case 5: levelDuration = 1.0
        default:
            levelDuration = 1.0
            print("Cannot find level info for Enemy1")
            
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
        
        let randomXStart = random(min:gameArea.minX , max:gameArea.maxX)
        let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1.5)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 3.5)
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
            let amountDraggedX = pointOfTouch.x - previousPointOfTouch.x
           // let amountDraggedY = pointOfTouch.y - previousPointOfTouch.y
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDraggedX
                //player.position.y += amountDraggedY
            }
            if player.position.x >= gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x <= gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
            
            
            if player.position.y >= gameArea.maxY - player.size.height/2 {
                player.position.y = gameArea.maxY - player.size.height/2
            }
        
            if player.position.y <= gameArea.minY + player.size.height/2 {
                player.position.y = gameArea.minY + player.size.height/2
            }
    
        
        }
        
        
    }
    
    func moveToNextGameScene(){
        
        let sceneToMoveTo = BossScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    func prepToMoveToNextLevel(){
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        self.enumerateChildNodes(withName: "EnemyTwo"){
            enemy, stop in
            enemy.removeAllActions()
        }

        
        
        
        let changeSceneAction = SKAction.run(moveToNextGameScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)

    }
    
    
    func spawnEnemyTwoMissile(spawnPosition: CGPoint){
        
        print("Spawn Enemy Two missile called")
        
        
        //let randomXStart = random(min: bossPossition.minX , max: bossPossition.maxX)
        //let randomXStart = random(min: bossPossition.x * 0.6, max:bossPossition.x * 1.4)
        let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
        
        let startPoint = CGPoint(x: spawnPosition.x, y: spawnPosition.y)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let bossMissile = SKSpriteNode(imageNamed: "bossMissile")
        bossMissile.name = "Enemy"
        bossMissile.setScale(1.0)
        bossMissile.position = startPoint
        bossMissile.zPosition = 2
        bossMissile.physicsBody = SKPhysicsBody(rectangleOf: bossMissile.size)
        bossMissile.physicsBody!.affectedByGravity = false
        bossMissile.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        bossMissile.physicsBody!.collisionBitMask = PhysicsCategories.None
        bossMissile.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(bossMissile)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2.7)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        
        if currentGameState == gameState.inGame{
            bossMissile.run(enemySequence)
            
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        bossMissile.zRotation = amountToRotate
        
        
        
    }

    func spawnEnemyTwo(){
        
        print("Spawn EnemyTwo Called")
        
        let randomXStart = random(min:gameArea.minX , max:gameArea.maxX)
        let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "Boss")
        enemy.name = "EnemyTwo"
        enemy.setScale(1.0)
        enemy.position = startPoint
        enemy.zPosition = 3
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 4.0)
        let enemyFire = SKAction.run {
            self.spawnEnemyTwoMissile(spawnPosition: enemy.position)
        }
        
        let enemyFireWait = SKAction.wait(forDuration: 0.6)
        let deleteEnemy = SKAction.removeFromParent()
        let enemyFireSquence = SKAction.sequence([enemyFireWait, enemyFire])
        let enemyFireForever = SKAction.repeatForever(enemyFireSquence)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        
        

    
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
            enemy.run(enemyFireForever)
        }
        
        /*let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate*/
        
        
        
    }

    
    func startAndSetEnemyTwoSpawn(){
        
        enemyTwoSpawnRate += 1
        
        if self.action(forKey: "spawningEnemiesTwo") != nil{
            self.removeAction(forKey: "spawningEnemiesTwo")
        }
        
        var levelDuration = TimeInterval()
        
            switch enemyTwoSpawnRate {
            case 1: levelDuration = 1.3
            case 2: levelDuration = 1.2
            case 3: levelDuration = 1.1
            default:
            levelDuration = 1.0
            print("Cannot find level info for EnemyTwo")

        }
        
        
        
        let spwan = SKAction.run(spawnEnemyTwo)
        let waitToSpwan = SKAction.wait(forDuration:levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpwan, spwan])
        let spwanForever = SKAction.repeatForever(spawnSequence)
        self.run(spwanForever, withKey: "spawningEnemiesTwo")
        
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
        if livesNumber == 0{
            runGameOver()
        }
        
    }

    
    
    func spawnLife(){
        
        let randomXStart = random(min:gameArea.minX , max:gameArea.maxX)
        let randomXEnd = random(min:gameArea.minX, max:gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
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
        
        let moveLife = SKAction.move(to: endPoint, duration: 4.0)
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
