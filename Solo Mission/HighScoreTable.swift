//
//  HighScoreTable.swift
//  Solo Mission
//
//  Created by Jonathon Poe on 4/16/18.
//  Copyright © 2018 Noblesite. All rights reserved.
//

import SpriteKit
import UIKit
class HighScoreTable: UITableView,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    var tableUpdateState = 0
    
    // JP updated for debugging
    var playersScores: [String:Int] = [:]
   
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.clear
        
        let backgroundImage = UIImage(named: "LaunchImage")
        let imageView = UIImageView(image: backgroundImage)
        self.backgroundView = imageView
        
        // JP updated for debubgging
        playersScores = getPlayerScores() as! [String:Int]
        
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
         self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        
           if(tableUpdateState == 0){
                return 2
          
           }else{
            
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableUpdateState == 0){
            
            if(section == 0){
                
                return 1
                
            }else{
                
                return playersScores.count
                
            }
            
        }else{
            
            return playersScores.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50;
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
    
        let cellHeight: Float = 50.0
        let frame: CGRect = CGRect(x: 0, y: 0, width: Int(tableView.bounds.width), height: Int(cellHeight))
        let cell = HighScoreCell(frame: frame, title: "Test");
        
        
        
       // (Array(playersScores).sorted{$0.1 > $1.1}).forEach{(k,v) in (playerNames.append(k), playerScores.append(v)) }
        
     
        var playerScores:[Int] = Array(playersScores.values)
        var playerNames:[String] = Array(playersScores.keys)
     
        
        
        //descending order array of indexes
        let sortedOrder = playerScores.enumerated().sorted(by: {$0.1>$1.1}).map({$0.0})
        
        //Map the arrays based on the new sortedOrder
        playerScores = sortedOrder.map({playerScores[$0]})
        playerNames = sortedOrder.map({playerNames[$0]})
        
        
      
        
        if(tableUpdateState == 0){
        
            if(indexPath.section == 0){
            
            
                cell.playerName.text = "Select Here"
                cell.playerName.isUserInteractionEnabled = true
                cell.playerName.delegate = self as UITextFieldDelegate
                cell.backgroundColor = UIColor(red: 99/255.0, green: 106/255.0, blue: 151/255.0, alpha: 1)
                cell.playerName.frame = CGRect(x: 0.0, y: 0.0, width: cell.bounds.width, height: cell.bounds.height)
                
            }else{
            
          
                cell.rankLabel.text = "Rank: \(indexPath.row + 1)"
              //  cell.playerScoreLabel.text = "Score: \(playerScores[indexPath.row])"
                cell.playerScoreLabel.text = "Score: \(String(playerScores[indexPath.row]))"
                //cell.playerName.text = playerNames[indexPath.row]
                cell.playerName.text = playerNames[indexPath.row]
                cell.playerName.isUserInteractionEnabled = false
            
         
            }
        
        }else{
            
            cell.rankLabel.text = "Rank: \(indexPath.row + 1)"
            cell.playerScoreLabel.text = "Score: \(playerScores[indexPath.row])"
            cell.playerName.text = playerNames[indexPath.row]
            cell.playerName.isUserInteractionEnabled = false
            
        }
        return cell
    
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let headerText = UILabel()
        headerText.textColor = UIColor.white
        headerText.adjustsFontSizeToFitWidth = true
        headerText.backgroundColor = UIColor.black
       
        if(tableUpdateState == 0){
            switch section{
            case 0:
                headerText.textAlignment = NSTextAlignment.center
                headerText.text = "Enter Your Name"
                headerText.font = UIFont(name: "The Bold Font", size: headerText.font.pointSize)
            case 1:
                headerText.textAlignment = NSTextAlignment.center
                headerText.text = "The Scoreboard"
                headerText.font = UIFont(name: "The Bold Font", size: headerText.font.pointSize)
            default:
                headerText.textAlignment = NSTextAlignment.center
                headerText.text = "The Scoreboard"
                headerText.font = UIFont(name: "The Bold Font", size: headerText.font.pointSize)
            }
        }else{
            
            headerText.textAlignment = NSTextAlignment.center
            headerText.text = "The Scoreboard"
            headerText.font = UIFont(name: "The Bold Font", size: headerText.font.pointSize)
            
        }
        return headerText
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        if(indexPath.section == 0){
            
            
        }
    }
    
    func setPlayerScores(dict: NSDictionary) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(dict, forKey: "AllPlayersScores")
        userDefaults.synchronize()
        tableUpdateState = 1
        self.reloadData()
       
   
    }
    
    func getPlayerScores() -> NSDictionary {
      
        if let tmp = UserDefaults.standard.dictionary(forKey: "AllPlayersScores"){
        
            return tmp as NSDictionary
            
      }else{
        
            let tmp:[String:Int] = [:]
        
            return tmp as NSDictionary
        }
    
    }
    
    func dismissKeyboard() {
        
        self.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        self.endEditing(true)
        
        if (textField.text != nil){
           
            updatePlayerScore(playerName: textField.text! as NSString)
       
        }else{
            
            
            
        }
        
        return false
    }
    
    func updatePlayerScore(playerName: NSString){
        
      
        playersScores.updateValue(gameScore, forKey: playerName as String)
        
        print("***** game score \(gameScore) *****")
        
        setPlayerScores(dict: playersScores as NSDictionary)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        
        textField.text = ""
    }
    
}


