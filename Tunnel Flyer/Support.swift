//
//  Support.swift
//  Tunnel Flyer
//
//  Created by Dan Goyette on 5/9/16.
//  Copyright © 2016 Dan Goyette. All rights reserved.
//

import SceneKit

class GameStats {
    var shipPitch : Float = 0.0
    var shipRoll : Float = 0.0
    var shipYaw : Float = 0.0
    var shipX : Float = 0.0
    var shipY : Float = 0.0
    var shipZ : Float = 0.0
    
    var shipEulerX : Float = 0.0
    var shipEulerY : Float = 0.0
    var shipEulerZ : Float = 0.0
    
}

class JoystickValues {
    var leftJoystickXValue : Float = 0.0
    var leftJoystickYValue : Float = 0.0
    var rightJoystickXValue : Float = 0.0
    var rightJoystickYValue : Float = 0.0
}

class NodePositionReference {
    init(n : SCNNode, p: SCNVector3) {
        self.node = n
        self.position = p
    }
    
    var node : SCNNode
    var position : SCNVector3
}