//
//  GameViewController.swift
//  Solo Mission
//
//  Created by Jonathon Poe on 11/10/16.
//  Copyright © 2016 Noblesite. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    var backingAudio = AVAudioPlayer()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "BackingAudio", ofType: "mp3")
        let audioNSURL = URL(fileURLWithPath: filePath!)
        
        do { backingAudio = try AVAudioPlayer(contentsOf: audioNSURL)}
        catch { return print("Cannot Find the Audio")}
        
        backingAudio.numberOfLoops = -1
        backingAudio.play()
        
        let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
            //configure the view
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        //sprit kit applies additional optiomzation to improve rendering
        skView.ignoresSiblingOrder = true
        
        // set the scale mode to call to fit the window
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
            }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
