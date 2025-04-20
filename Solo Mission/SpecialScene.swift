//
//  SpecialScene.swift
//  Solo Mission
//
//  Created by Jonathon Poe on 11/11/16.
//  Copyright © 2016 Noblesite. All rights reserved.
//

import Foundation
import SpriteKit

class SpecialScene: SKScene{
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background3")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2.0, y: self.size.height/2.0)
        background.zPosition = 0
        self.addChild(background)
        
        let gameBy = SKLabelNode(fontNamed: "Emulogic")
        gameBy.text = "Astrid"
        gameBy.fontSize = 190
        gameBy.fontColor = SKColor.black
        gameBy.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.8)
        gameBy.zPosition = 1
        self.addChild(gameBy)
        
        let restartLabel = SKLabelNode(fontNamed: "Emulogic")
        restartLabel.text = "Press to Play Again"
        restartLabel.fontSize = 40
        restartLabel.fontColor = SKColor.black
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.2)
        self.addChild(restartLabel)
        
        
    }
    
    
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        let sceneToMoveTo = GameScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    
    
    
    
}
