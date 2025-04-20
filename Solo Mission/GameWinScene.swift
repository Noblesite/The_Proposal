//
//  GameOverScene.swift
//  Solo Mission
//
//  Created by Jonathon Poe on 11/11/16.
//  Copyright © 2016 Noblesite. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameWinScene: SKScene{
    

    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let saveScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let backLabel = SKLabelNode(fontNamed: "The Bold Font")
    let gameTableView = HighScoreTable()
    var backLabelEnabled = 0
    
    override func didMove(to view: SKView) {
        
        let backGround = SKSpriteNode(imageNamed: "background2")
        backGround.size = self.size
        backGround.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backGround.zPosition = 0
        self.addChild(backGround)
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "You Win!"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 150
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highScoreNumber{
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        self.addChild(highScoreLabel)
        
        
        restartLabel.text = "Press to play again!"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(restartLabel)
        
        saveScoreLabel.text = "Press to Save Your Score!"
        saveScoreLabel.fontSize = 80
        saveScoreLabel.fontColor = SKColor.white
        saveScoreLabel.zPosition = 1
        saveScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.2)
        self.addChild(saveScoreLabel)
        
        backLabel.text = "Close Scoreboard"
        backLabel.fontSize = 120
        backLabel.fontColor = SKColor.white
        backLabel.zPosition = 1
        backLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.85)
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch){
                
                let sceneToMoveTo = SpecialScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
            }
            
            if saveScoreLabel.contains(pointOfTouch){
                
                let screenSize = UIScreen.main.bounds
                
                // Table setup
                gameTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                gameTableView.frame=CGRect(x:screenSize.width * 0.10,y:screenSize.height * 0.20,width:screenSize.width * 0.80,height:screenSize.height * 0.70)
                self.scene?.view?.addSubview(gameTableView)
                self.addChild(backLabel)
                gameTableView.reloadData()
                backLabelEnabled = 1
                
            }
            
            if backLabel.contains(pointOfTouch){
                if backLabelEnabled == 1 {
                    
                    gameTableView.removeFromSuperview()
                    backLabel.removeFromParent()
                    backLabelEnabled = 0
                    saveScoreLabel.removeFromParent()
                }
                
                
            }
            
        }
        
    }
}

