//
//  HighScoreCell.swift
//  Solo Mission
//
//  Created by Jonathon Poe on 4/9/18.
//  Copyright © 2018 Noblesite. All rights reserved.
//

import UIKit

class HighScoreCell: UITableViewCell {

    var rankLabel: UILabel!
    var playerScoreLabel: UILabel!
    var playerName: UITextField!
    
    
    init(frame: CGRect, title: String) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
     
        rankLabel = UILabel(frame: CGRect(x:0, y:0, width: frame.width * 0.20, height:frame.height * 0.90))
        
        rankLabel.font = UIFont(name: "The Bold Font", size: rankLabel.font.pointSize)
        
        rankLabel.textColor = UIColor.white
        
        rankLabel.adjustsFontSizeToFitWidth = true
        
        playerScoreLabel = UILabel(frame: CGRect(x:frame.width * 0.25, y: frame.height * 0.05, width: frame.width * 0.70, height: frame.height * 0.40))
        
        playerScoreLabel.font = UIFont(name: "The Bold Font", size: rankLabel.font.pointSize)
        
        playerScoreLabel.textColor = UIColor.white
        
        playerScoreLabel.adjustsFontSizeToFitWidth = true
        
        playerName = UITextField(frame: CGRect(x:frame.width * 0.25, y: frame.height * 0.45, width: frame.width * 0.70, height: frame.height * 0.50))
        
        playerName.textColor = UIColor.white
        playerName.font = UIFont(name: "The Bold Font", size: rankLabel.font.pointSize)
        self.backgroundColor = UIColor.clear
        playerName.textAlignment = NSTextAlignment.center
        addSubview(rankLabel)
        addSubview(playerScoreLabel)
        addSubview(playerName)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    


}
