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
    
    var upNode: SKSpriteNode!
    var downNode: SKSpriteNode!
    var rightNode: SKSpriteNode!
    var leftNode: SKSpriteNode!
    var upPressed: Bool = false
    var downPressed: Bool = false
    var leftPressed: Bool = false
    var rightPressed: Bool = false
  
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clearColor()
        
        let spriteSize = size.width/15
        
        upNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(spriteSize, spriteSize))
        upNode.position = CGPoint(x: 2 * spriteSize, y: 3 * spriteSize)
        downNode = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(spriteSize, spriteSize))
        downNode.position = CGPoint(x: 2 * spriteSize, y: spriteSize)
        leftNode = SKSpriteNode(color: UIColor.purpleColor(), size: CGSizeMake(spriteSize, spriteSize))
        leftNode.position = CGPoint(x: spriteSize , y: 2 * spriteSize )
        rightNode = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(spriteSize, spriteSize))
        rightNode.position = CGPoint(x: 3 * spriteSize, y: 2 * spriteSize)

       
        self.addChild(self.upNode)
        self.addChild(self.downNode)
        self.addChild(self.leftNode)
        self.addChild(self.rightNode)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (touches.count > 0) {
            for touch in touches {
                let location = touch.locationInNode(self)
                
                if self.upNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["up": true])
                }
                if self.downNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["down": true])
                }
                if self.leftNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["left": true])
                }
                if self.rightNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["right": true])
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (touches.count > 0) {
            for touch in touches {
                let location = touch.locationInNode(self)
                
                if self.upNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["up": false])
                }
                if self.downNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["down": false])
                }
                if self.leftNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["left": false])
                }
                if self.rightNode.containsPoint(location) {
                    NSNotificationCenter.defaultCenter().postNotificationName(directionPressedNotificationKey, object: nil, userInfo:["right": false])
                }
            }
        }
    }
}