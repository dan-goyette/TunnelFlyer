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

    var leftJoyStickDefaultLocation: CGPoint!
    var leftJoyStickNode: SKSpriteNode!
    var leftJoyStickNodeIsDown: Bool = false
    var leftJoyStickTouch: UITouch?
    
    var rightJoyStickDefaultLocation: CGPoint!
    var rightJoyStickNode: SKSpriteNode!
    var rightJoyStickNodeIsDown: Bool = false
    var rightJoyStickTouch: UITouch?
    
    
    var diagLabel1 : SKLabelNode!
    var diagLabel2 : SKLabelNode!
    var diagLabel3 : SKLabelNode!

    var spriteSize : CGFloat!
    
    var leftJoystickXValue : Float = 0.0
    var rightJoystickXValue : Float = 0.0
    var leftJoystickYValue : Float = 0.0
    var rightJoystickYValue : Float = 0.0
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clearColor()
        
        spriteSize = size.width/15
        
        
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
        
        
        leftJoyStickNode = SKSpriteNode(color: UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), size: CGSizeMake(spriteSize, spriteSize))
        leftJoyStickDefaultLocation = CGPoint(x: 2 * spriteSize, y: 4 * spriteSize)
        leftJoyStickNode.position = leftJoyStickDefaultLocation
        self.addChild(self.leftJoyStickNode)
        
        rightJoyStickNode = SKSpriteNode(color: UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), size: CGSizeMake(spriteSize, spriteSize))
        rightJoyStickDefaultLocation = CGPoint(x: size.width - 2 * spriteSize, y: 4 * spriteSize)
        rightJoyStickNode.position = rightJoyStickDefaultLocation
        self.addChild(self.rightJoyStickNode)
        
        // Listen for GameStats changes, so we update the stats
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OverlayScene.gameStatsUpdated(_:)), name: gameStatsUpdatedNotificationKey, object: nil)
    }
    
    
    func gameStatsUpdated(notification: NSNotification) {
        if let gameStats = notification.userInfo?["gameStats"] as? GameStats {
            diagLabel1.text = String(format: "X: %.4f; Y: %.4f; Z: %.4f", gameStats.shipX, gameStats.shipY, gameStats.shipZ)
            diagLabel2.text = String(format: "Pitch: %.4f; Roll: %.4f; Euler X/Y/Z: %.2f/%.2f/%.2f", gameStats.shipPitch, gameStats.shipRoll, gameStats.shipEulerX, gameStats.shipEulerY, gameStats.shipEulerZ)
            diagLabel3.text = String(format: "Left Joy: %.4f; Right Joy: %.4f;", self.leftJoystickYValue, self.rightJoystickYValue)
        }
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        
        var joystickValueChanged = false
        
        let currentLeftJoystickRelativeYValue = Float((self.leftJoyStickNode.position.y - leftJoyStickDefaultLocation.y) / spriteSize)
        if (currentLeftJoystickRelativeYValue != leftJoystickYValue) {
            joystickValueChanged = true
            
        }
        leftJoystickYValue = currentLeftJoystickRelativeYValue
        let currentLeftJoystickRelativeXValue = Float((self.leftJoyStickNode.position.x - leftJoyStickDefaultLocation.x) / spriteSize)
        if (currentLeftJoystickRelativeXValue != leftJoystickXValue) {
            joystickValueChanged = true
            
        }
        leftJoystickXValue = currentLeftJoystickRelativeXValue
        
        
      
        let currentRightJoystickRelativeYValue = Float((self.rightJoyStickNode.position.y - rightJoyStickDefaultLocation.y) / spriteSize)
        if (currentRightJoystickRelativeYValue != rightJoystickYValue) {
            joystickValueChanged = true
            
        }
        rightJoystickYValue = currentRightJoystickRelativeYValue
        let currentRightJoystickRelativeXValue = Float((self.rightJoyStickNode.position.x - rightJoyStickDefaultLocation.x) / spriteSize)
        if (currentRightJoystickRelativeXValue != rightJoystickXValue) {
            joystickValueChanged = true
            
        }
        rightJoystickXValue = currentRightJoystickRelativeXValue
        
        

        if (joystickValueChanged) {
            let joystickValues = JoystickValues()
            joystickValues.leftJoystickXValue = leftJoystickXValue
            joystickValues.leftJoystickYValue = leftJoystickYValue
            joystickValues.rightJoystickXValue = rightJoystickXValue
            joystickValues.rightJoystickYValue = rightJoystickYValue
            NSNotificationCenter.defaultCenter().postNotificationName(joystickValueChangedNotificationKey, object: nil, userInfo:["joystickValues": joystickValues])
            
        }
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
        
        if (touches.count > 0) {
            for touch in touches {
                if (touch == self.leftJoyStickTouch) {
                    self.leftJoyStickNode.position.x = touch.locationInNode(self).x
                    self.leftJoyStickNode.position.y = touch.locationInNode(self).y
                    
                    if (self.leftJoyStickNode.position.x < leftJoyStickDefaultLocation.x - spriteSize) {
                        self.leftJoyStickNode.position.x = leftJoyStickDefaultLocation.x - spriteSize
                    } else if (self.leftJoyStickNode.position.x > leftJoyStickDefaultLocation.x + spriteSize) {
                        self.leftJoyStickNode.position.x = leftJoyStickDefaultLocation.x + spriteSize
                    }
                    if (self.leftJoyStickNode.position.y < leftJoyStickDefaultLocation.y - spriteSize) {
                        self.leftJoyStickNode.position.y = leftJoyStickDefaultLocation.y - spriteSize
                    } else if (self.leftJoyStickNode.position.y > leftJoyStickDefaultLocation.y + spriteSize) {
                        self.leftJoyStickNode.position.y = leftJoyStickDefaultLocation.y + spriteSize
                    }
                  
                }
                
                
                if (touch == self.rightJoyStickTouch) {
                    self.rightJoyStickNode.position.x = touch.locationInNode(self).x
                    self.rightJoyStickNode.position.y = touch.locationInNode(self).y

                    
                    if (self.rightJoyStickNode.position.x < rightJoyStickDefaultLocation.x - spriteSize) {
                        self.rightJoyStickNode.position.x = rightJoyStickDefaultLocation.x - spriteSize
                    } else if (self.rightJoyStickNode.position.x > rightJoyStickDefaultLocation.x + spriteSize) {
                        self.rightJoyStickNode.position.x = rightJoyStickDefaultLocation.x + spriteSize
                    }
                    if (self.rightJoyStickNode.position.y < rightJoyStickDefaultLocation.y - spriteSize) {
                        self.rightJoyStickNode.position.y = rightJoyStickDefaultLocation.y - spriteSize
                    } else if (self.rightJoyStickNode.position.y > rightJoyStickDefaultLocation.y + spriteSize) {
                        self.rightJoyStickNode.position.y = rightJoyStickDefaultLocation.y + spriteSize
                    }
                    
                }
            }
        }
        
       
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (touches.count > 0) {
            for touch in touches {
//                let location = touch.locationInNode(self)
                
                
                if (touch == self.leftJoyStickTouch) {
                    self.leftJoyStickTouch = nil
                    self.leftJoyStickNodeIsDown = false
                    leftJoyStickNode.runAction(SKAction.moveTo(leftJoyStickDefaultLocation, duration: 0.25))
                }
                if (touch == self.rightJoyStickTouch) {
                    self.rightJoyStickTouch = nil
                    self.rightJoyStickNodeIsDown = false
                    rightJoyStickNode.runAction(SKAction.moveTo(rightJoyStickDefaultLocation, duration: 0.25))
                }
            }
        }
    }
}