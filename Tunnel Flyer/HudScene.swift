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

    var leftJoyStickNode: SKSpriteNode!
    var leftJoyStickNodeIsDown: Bool = false
    var leftJoyStickTouch: UITouch?
    
    var rightJoyStickNode: SKSpriteNode!
    var rightJoyStickNodeIsDown: Bool = false
    var rightJoyStickTouch: UITouch?
    
    
    var diagLabel1 : SKLabelNode!
    var diagLabel2 : SKLabelNode!
    var diagLabel3 : SKLabelNode!

    var maxJoyStickYValue : CGFloat!
    var minJoyStickYValue : CGFloat!
    
    var leftJoystickValue : Float = 0.0
    var rightJoystickValue : Float = 0.0
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clearColor()
        
        let spriteSize = size.width/15
        
        
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
        
        maxJoyStickYValue = size.height - 4 * spriteSize
        minJoyStickYValue = 4 * spriteSize
        
        leftJoyStickNode = SKSpriteNode(color: UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), size: CGSizeMake(spriteSize, spriteSize))
        leftJoyStickNode.position = CGPoint(x: 1.5 * spriteSize, y: (maxJoyStickYValue + minJoyStickYValue) / 2.0)
        self.addChild(self.leftJoyStickNode)
        
        rightJoyStickNode = SKSpriteNode(color: UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), size: CGSizeMake(spriteSize, spriteSize))
        rightJoyStickNode.position = CGPoint(x: size.width - 1.5 * spriteSize, y: (maxJoyStickYValue + minJoyStickYValue) / 2.0)
        self.addChild(self.rightJoyStickNode)
        
        // Listen for GameStats changes, so we update the stats
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OverlayScene.gameStatsUpdated(_:)), name: gameStatsUpdatedNotificationKey, object: nil)
    }
    
    
    func gameStatsUpdated(notification: NSNotification) {
        if let gameStats = notification.userInfo?["gameStats"] as? GameStats {
            diagLabel1.text = String(format: "X: %.4f; Y: %.4f; Z: %.4f", gameStats.shipX, gameStats.shipY, gameStats.shipZ)
            diagLabel2.text = String(format: "Pitch: %.4f; Roll: %.4f", gameStats.shipPitch, gameStats.shipRoll)
            diagLabel3.text = String(format: "Left Joy: %.4f; Right Joy: %.4f", self.leftJoystickValue, self.rightJoystickValue)
        }
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (touches.count > 0) {
            for touch in touches {
                let location = touch.locationInNode(self)
                
                if (self.leftJoyStickNode.containsPoint(location)) {
                    if (self.leftJoyStickTouch == nil) {
                        self.leftJoyStickTouch = touch
                        self.leftJoyStickNodeIsDown = true
                    }
                }
                if (self.rightJoyStickNode.containsPoint(location)) {
                    if (self.rightJoyStickTouch == nil) {
                        self.rightJoyStickTouch = touch
                        self.rightJoyStickNodeIsDown = true
                    }
                }

            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var joystickValueChanged = false
        
        if (touches.count > 0) {
            for touch in touches {
                if (touch == self.leftJoyStickTouch) {
                    self.leftJoyStickNode.position.y = touch.locationInNode(self).y
                    if (self.leftJoyStickNode.position.y < minJoyStickYValue) {
                        self.leftJoyStickNode.position.y = minJoyStickYValue
                    } else if (self.leftJoyStickNode.position.y > maxJoyStickYValue) {
                        self.leftJoyStickNode.position.y = maxJoyStickYValue
                    }
                    
                    let joyAvg = (maxJoyStickYValue + minJoyStickYValue) / 2.0
                    let newMax = maxJoyStickYValue - joyAvg

                    let newLeftJoystickAmount = Float((self.leftJoyStickNode.position.y - joyAvg) / newMax)
                    if (newLeftJoystickAmount != leftJoystickValue) {
                        joystickValueChanged = true
                        
                    }
                    leftJoystickValue = newLeftJoystickAmount
                }
                
                
                if (touch == self.rightJoyStickTouch) {
                    self.rightJoyStickNode.position.y = touch.locationInNode(self).y
                    if (self.rightJoyStickNode.position.y < minJoyStickYValue) {
                        self.rightJoyStickNode.position.y = minJoyStickYValue
                    } else if (self.rightJoyStickNode.position.y > maxJoyStickYValue) {
                        self.rightJoyStickNode.position.y = maxJoyStickYValue
                    }
                    
                    let joyAvg = (maxJoyStickYValue + minJoyStickYValue) / 2.0
                    let newMax = maxJoyStickYValue - joyAvg
                    
                    let newRightJoystickAmount = Float((self.rightJoyStickNode.position.y - joyAvg) / newMax)
                    if (newRightJoystickAmount != rightJoystickValue) {
                        joystickValueChanged = true
                        
                    }
                    rightJoystickValue = newRightJoystickAmount
                }
            }
        }
        
        if (joystickValueChanged) {
            let joystickValues = JoystickValues()
            joystickValues.leftJoystickValue = leftJoystickValue
            joystickValues.rightJoystickValue = rightJoystickValue
            NSNotificationCenter.defaultCenter().postNotificationName(joystickValueChangedNotificationKey, object: nil, userInfo:["joystickValues": joystickValues])

        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (touches.count > 0) {
            for touch in touches {
//                let location = touch.locationInNode(self)
                
                
                if (touch == self.leftJoyStickTouch) {
                    self.leftJoyStickTouch = nil
                    self.leftJoyStickNodeIsDown = false
                }
                if (touch == self.rightJoyStickTouch) {
                    self.rightJoyStickTouch = nil
                    self.rightJoyStickNodeIsDown = false
                }
            }
        }
    }
}