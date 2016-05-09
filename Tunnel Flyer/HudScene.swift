//
//  HudScene.swift
//  Tunnel Flyer
//
//  Created by Dan Goyette on 5/8/16.
//  Copyright © 2016 Dan Goyette. All rights reserved.
//

import UIKit
import SpriteKit


class OverlayScene: SKScene {
    
    var leftUpNode: SKSpriteNode!
    var leftDownNode: SKSpriteNode!
    var rightUpNode: SKSpriteNode!
    var rightDownNode: SKSpriteNode!
    var leftUpPressed: Bool = false
    var leftDownPressed: Bool = false
    var rightUpPressed: Bool = false
    var rightDownPressed: Bool = false
    
    
    var diagLabel1 : SKLabelNode!
    var diagLabel2 : SKLabelNode!
    var diagLabel3 : SKLabelNode!

  
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clearColor()
        
        let spriteSize = size.width/15
        
        leftUpNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(spriteSize, spriteSize))
        leftUpNode.position = CGPoint(x: spriteSize, y: 3 * spriteSize)
        leftDownNode = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(spriteSize, spriteSize))
        leftDownNode.position = CGPoint(x: spriteSize, y: spriteSize)
        
        rightUpNode = SKSpriteNode(color: UIColor.purpleColor(), size: CGSizeMake(spriteSize, spriteSize))
        rightUpNode.position = CGPoint(x: size.width - 2 * spriteSize , y: 3 * spriteSize )
        rightDownNode = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(spriteSize, spriteSize))
        rightDownNode.position = CGPoint(x: size.width - 2 * spriteSize, y: spriteSize)

       
        self.addChild(self.leftUpNode)
        self.addChild(self.leftDownNode)
        self.addChild(self.rightUpNode)
        self.addChild(self.rightDownNode)
        
        diagLabel1 = SKLabelNode()
        diagLabel1.position = CGPoint(x: 3 * spriteSize, y: 2 * spriteSize)
        diagLabel1.fontSize = 16
        diagLabel1.fontName = "AvenirNext-Bold"
        diagLabel1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        diagLabel2 = SKLabelNode()
        diagLabel2.position = CGPoint(x: 3 * spriteSize, y: 1.5 * spriteSize)
        diagLabel2.fontSize = 16
        diagLabel2.fontName = "AvenirNext-Bold"
        diagLabel2.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        diagLabel3 = SKLabelNode()
        diagLabel3.position = CGPoint(x: 3 * spriteSize, y: 1 * spriteSize)
        diagLabel3.fontSize = 16
        diagLabel3.fontName = "AvenirNext-Bold"
        diagLabel3.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        self.addChild(self.diagLabel1)
        self.addChild(self.diagLabel2)
        self.addChild(self.diagLabel3)


        
        // Listen for GameStats changes, so we update the stats
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OverlayScene.gameStatsUpdated(_:)), name: gameStatsUpdatedNotificationKey, object: nil)
        

    }
    
    
    func gameStatsUpdated(notification: NSNotification) {
        if let gameStats = notification.userInfo?["gameStats"] as? GameStats {
            diagLabel1.text = String(format: "X: %.4f; Y: %.4f; Z: %.4f", gameStats.shipX, gameStats.shipY, gameStats.shipZ)
            diagLabel2.text = String(format: "Pitch: %.4f; Roll: %.4f", gameStats.shipPitch, gameStats.shipRoll)
        }
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (touches.count > 0) {
            for touch in touches {
                let location = touch.locationInNode(self)
                
                if self.leftUpNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["leftUp": true])
                }
                if self.leftDownNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["leftDown": true])
                }
                if self.rightUpNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["rightUp": true])
                }
                if self.rightDownNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["rightDown": true])
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (touches.count > 0) {
            for touch in touches {
                let location = touch.locationInNode(self)
                
                if self.leftUpNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["leftUp": false])
                }
                if self.leftDownNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["leftDown": false])
                }
                if self.rightUpNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["rightUp": false])
                }
                if self.rightDownNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["rightDown": false])
                }
            }
        }
    }
}