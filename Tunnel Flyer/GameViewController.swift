//
//  GameViewController.swift
//  Tunnel Flyer
//
//  Created by Dan Goyette on 5/4/16.
//  Copyright (c) 2016 Dan Goyette. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

let joystickValueChangedNotificationKey = "com.dan-goyette.TunnerlFlyer.joystickValueChangedNotificationKey"
let gameStatsUpdatedNotificationKey = "com.dan-goyette.TunnerlFlyer.gameStatsUpdatedNotificationKey"

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    let scene = SCNScene()

    
    let DRAW_DISTANCE : Float = 100.0
    let RING_SIZE_MULTIPLIER : Float = 15
    let RING_VARIANCE_MIN : Float = -5.0
    let RING_VARIANCE_MAX : Float = 5.0
    let CAMERA_SPEED : Float = 0.35
    let HEX_RING_Z_INTERVAL : Float = 5
    let SHIP_MOVEMENT_SPEED : Float = 80.0
    let SHIP_TERMINAL_SPEED : Float = 100.0
    let SHIP_PITCH_INTERVAL : Float = 0.5
    let SHIP_ROLL_INTERVAL : Float = 0.5
    let SHIP_YAW_INTERVAL : Float = 0.5
    let BASE_SHIP_EULER_X : Float = -1 * Float(M_PI_2)
    
    
    var currentMaxDistance = 0
    
    var lastHexRing : [SCNVector3]? = nil
    var hexRingZ : Float = 0
    var shipNode : SCNNode!
    var shipPitchNode: SCNNode!
    var shipRollNode: SCNNode!
    var shipYawNode: SCNNode!
    
    
    
    
    var unifiedCameraShipNode : SCNNode!
    
    var cameraNode = SCNNode()
    
    var shipRoll : Float = 0
    var shipPitch : Float = 0
    var shipYaw : Float = 0
    
    var joystickValues : JoystickValues = JoystickValues()
    
    
    var hudScene :  SKScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If the unified node doesn't have some underlying shape, then the physics simulation won't be applied to it.
        let unifiedCameraShipNodeShape = SCNShape()
        unifiedCameraShipNode = SCNNode(geometry: unifiedCameraShipNodeShape)
        let unifiedPhysicsBody = SCNPhysicsBody(type: .Dynamic, shape: nil)
        unifiedPhysicsBody.angularDamping = 0.999
        unifiedPhysicsBody.damping = 0.9
        unifiedCameraShipNode.physicsBody = unifiedPhysicsBody
        unifiedPhysicsBody.affectedByGravity = false
        
        // Create ship
        createShip()
        
       
     
        
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        // Relative to the unified camera ship, the camera is 15z closer to the viewer.
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 10)
        
        let cameraConstraint = SCNLookAtConstraint(target: shipNode)
        cameraConstraint.gimbalLockEnabled = true
        cameraNode.constraints = [cameraConstraint]
        
        unifiedCameraShipNode.addChildNode(cameraNode)
        
        
        scene.rootNode.addChildNode(unifiedCameraShipNode)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
      
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        
        scnView.delegate = self
        
        
        // set the scene to the view
        scnView.scene = scene
        
        scnView.autoenablesDefaultLighting = false
        
        // Enter render loop at every frame.
        scnView.playing = true;
        
        // prevents the user from manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()

        //scnView.debugOptions = .ShowPhysicsShapes
        
        
        createHudScene()
        scnView.overlaySKScene = hudScene

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.joystickValueChanged(_:)), name: joystickValueChangedNotificationKey, object: nil)
        
    }
    
    func joystickValueChanged(notification: NSNotification) {
        if let newValues = notification.userInfo?["joystickValues"] as? JoystickValues {
            joystickValues = newValues
        }
    }
    
    
  
    
    func createHudScene() {
        hudScene = OverlayScene(size: self.view.bounds.size)
    }
    
    func createHexRing( z : Float) -> [SCNVector3] {
        var ring = [SCNVector3]()
        

        
        ring.append(SCNVector3Make(-3 * RING_SIZE_MULTIPLIER + getHexVariance(), 0 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(-2 * RING_SIZE_MULTIPLIER + getHexVariance(), 1 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(-1 * RING_SIZE_MULTIPLIER + getHexVariance(), 2 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(0 * RING_SIZE_MULTIPLIER + getHexVariance(), 3 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(1 * RING_SIZE_MULTIPLIER + getHexVariance(), 2 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(2 * RING_SIZE_MULTIPLIER + getHexVariance(), 1 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(3 * RING_SIZE_MULTIPLIER + getHexVariance(), 0 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(2 * RING_SIZE_MULTIPLIER + getHexVariance(), -1 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(1 * RING_SIZE_MULTIPLIER + getHexVariance(), -2 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(0 * RING_SIZE_MULTIPLIER + getHexVariance(), -3 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(-1 * RING_SIZE_MULTIPLIER + getHexVariance(), -2 * RING_SIZE_MULTIPLIER + getHexVariance(), z))
        ring.append(SCNVector3Make(-2 * RING_SIZE_MULTIPLIER +  getHexVariance(), -1 * RING_SIZE_MULTIPLIER + getHexVariance(), z))


        return ring
    
    }
    
    func randomBetweenNumbers(firstNum: Float, secondNum: Float) -> Float{
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        // If the last ring is too close, draw another ring.
        while (self.hexRingZ - unifiedCameraShipNode.presentationNode.position.z > (-1 * self.DRAW_DISTANCE) ) {
            self.addTunnelSection()
            
            if (self.hexRingZ % 10 == 0) {
                createDebris()
            }
        }
        

        shipRoll = -1.0 * exaggerate( joystickValues.rightJoystickXValue) * SHIP_ROLL_INTERVAL
        shipPitch =  -1.0 * exaggerate( joystickValues.leftJoystickYValue) *  SHIP_PITCH_INTERVAL
        shipYaw = -1.0 * exaggerate( joystickValues.leftJoystickXValue)  * SHIP_YAW_INTERVAL
        
        let speedVector = SCNVector3ToGLKVector3(unifiedCameraShipNode.physicsBody!.velocity)
        let speed = GLKVector3Length(speedVector)
  
    
        let shipSpeed = -1 * SHIP_MOVEMENT_SPEED - SHIP_MOVEMENT_SPEED * (1 + joystickValues.rightJoystickYValue) * (max(0, (SHIP_TERMINAL_SPEED - speed)) / SHIP_TERMINAL_SPEED)
        
        
        
        // Adjust ship speed to reduce it as the ship approaches terminal velocity.
        
        
        let gameStats = GameStats()
        gameStats.shipX = unifiedCameraShipNode.position.x
        gameStats.shipY = unifiedCameraShipNode.position.y
        gameStats.shipZ = unifiedCameraShipNode.position.z
        
        gameStats.shipEulerX = unifiedCameraShipNode.eulerAngles.x
        gameStats.shipEulerY = unifiedCameraShipNode.eulerAngles.y
        gameStats.shipEulerZ = unifiedCameraShipNode.eulerAngles.z
        
        
        shipPitchNode.rotation.w = shipPitch
        shipRollNode.rotation.w = shipRoll
        shipYawNode.rotation.w = shipYaw
        
        
        

        // Move the ship "forward" in its direction of travel.
        
        let forwardForce = SCNVector3Make(0, 0, shipSpeed )
        
        let rotationVector = unifiedCameraShipNode.presentationNode.rotation
        
        unifiedCameraShipNode.physicsBody!.applyForce(applyRotationToVector(rotationVector, vector: forwardForce), atPosition: applyRotationToVector(rotationVector, vector: SCNVector3(x: 0.0, y: 0.0, z: 0.0)), impulse: false)
        
        
        let yawForce = SCNVector3Make(shipYaw, 0, 0)
        unifiedCameraShipNode.physicsBody!.applyForce(applyRotationToVector(rotationVector, vector: yawForce), atPosition: applyRotationToVector(rotationVector, vector: SCNVector3(x: 0.0, y: 0.0, z: 1.0)), impulse: false)
        
        let pitchForce = SCNVector3Make(0, shipPitch, 0)
        unifiedCameraShipNode.physicsBody!.applyForce(applyRotationToVector(rotationVector, vector: pitchForce), atPosition: applyRotationToVector(rotationVector, vector: SCNVector3(x: 0.0, y: 0.0, z: -1.0)), impulse: false)
        
        let rollForce = SCNVector3Make(0, shipRoll, 0 )
        unifiedCameraShipNode.physicsBody!.applyForce(applyRotationToVector(rotationVector, vector: rollForce), atPosition: applyRotationToVector(rotationVector, vector: SCNVector3(x: -1, y: 0, z: 0.0)), impulse: false)
        
        
        
        
        
        //NSNotificationCenter.defaultCenter().postNotificationName(gameStatsUpdatedNotificationKey, object: nil, userInfo:["gameStats": gameStats])

    }
    
    func exaggerate(value : Float) -> Float {
        return powf(value, 3)// * getSign(value)
    }

    func getSign(value : Float) -> Float {
        return value < 0 ? -1 : 1
    }
    
    func applyRotationToVector(rotation : SCNVector4, vector: SCNVector3) -> SCNVector3 {
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let glkMatrix = SCNMatrix4ToGLKMatrix4(rotationMatrix)
        let glkVector = SCNVector3ToGLKVector3(vector)
        let resultVector = GLKMatrix4MultiplyVector3(glkMatrix, glkVector)
        return SCNVector3FromGLKVector3(resultVector)
    }
    
    func createDebris() {
        let cube = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 2)
        
        let material = SCNMaterial()
        material.doubleSided = true
        material.diffuse.contents = getRandomColor()
        
        cube.materials = [material]
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position.z = self.hexRingZ
        
        cubeNode.position.x = randomBetweenNumbers( -12.0, secondNum: 12.0)
        cubeNode.position.y = randomBetweenNumbers( -12.0, secondNum: 12.0)
        cubeNode.position.z = self.hexRingZ

        
        let rotate = SCNAction.rotateByX(2.1, y: 0.3, z: 1.1, duration: 1.0)
        let rotateLoop = SCNAction.repeatActionForever(rotate)
        cubeNode.runAction(rotateLoop)
        
        let move = SCNAction.moveByX(CGFloat(randomBetweenNumbers( -3.0, secondNum: 3.0)), y: CGFloat(randomBetweenNumbers( -3.0, secondNum: 3.0)), z: CGFloat(randomBetweenNumbers( -3.0, secondNum: 3.0)), duration: 1)
        let moveLoop = SCNAction.repeatActionForever(move)
        cubeNode.runAction(moveLoop)
        
        scene.rootNode.addChildNode(cubeNode)

    }
    
    
    func addTunnelSection() {
        if (self.lastHexRing == nil) {
            self.lastHexRing = self.createHexRing(self.hexRingZ)
            self.hexRingZ -= self.HEX_RING_Z_INTERVAL
        }
        
        let nextRing = self.createHexRing(self.hexRingZ)
        self.hexRingZ -= self.HEX_RING_Z_INTERVAL
        drawRingConnections(self.lastHexRing!, ring2: nextRing)
        
        self.lastHexRing = nextRing
    }
    
    func drawRingConnections(ring1 : [SCNVector3], ring2: [SCNVector3]) {
        
        
        for j in 0...(ring1.count - 1) {
            let triangle1Point1 = ring1[j % ring1.count]
            let triangle1Point2 = ring1[(j + 1) % ring1.count]
            let triangle1Point3 = ring2[j % ring1.count]

            addTriangleFromPositions(scene, point1: triangle1Point1, point2: triangle1Point2, point3: triangle1Point3)

            let triangle2Point1 = ring1[(j + 1) % ring1.count]
            let triangle2Point2 = ring2[(j + 1) % ring1.count]
            let triangle2Point3 = ring2[j % ring1.count]

            addTriangleFromPositions(scene, point1: triangle2Point1, point2: triangle2Point2, point3: triangle2Point3)

        }
    }
    
    func getHexVariance() -> Float {
        return randomBetweenNumbers( self.RING_VARIANCE_MIN, secondNum: self.RING_VARIANCE_MAX)
    }
    
    func addTriangleFromPositions(scene: SCNScene, point1: SCNVector3, point2: SCNVector3, point3: SCNVector3)
    {
        let positions: [Float32] = [point1.x, point1.y, point1.z, point2.x, point2.y, point2.z, point3.x, point3.y, point3.z,]
        let positionData = NSData(bytes: positions, length: sizeof(Float32)*positions.count)
        let indices: [Int32] = [0, 1, 2]
        let indexData = NSData(bytes: indices, length: sizeof(Int32) * indices.count)
        
        let source = SCNGeometrySource(data: positionData, semantic: SCNGeometrySourceSemanticVertex, vectorCount: indices.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32) * 3)
        let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Triangles, primitiveCount: indices.count, bytesPerIndex: sizeof(Int32))
        
        let triangle = SCNGeometry(sources: [source], elements: [element])
        
        let material = SCNMaterial()
        material.doubleSided = true
        material.diffuse.contents = getRandomShadeOfColor(UIColor(red: 41.0 / 256.0, green: 16.0 / 256.0, blue: 0, alpha: 1 ), isLight: false)


        
        triangle.materials = [material]
        let shapeNode = SCNNode(geometry: triangle)
        scene.rootNode.addChildNode(shapeNode)

    }
    
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func getRandomShadeOfColor(color : UIColor, isLight : Bool = true) -> UIColor {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var l : CGFloat = 0
        var a : CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &l, alpha: &a)
        
        
        let adjust = isLight ? CGFloat(randomBetweenNumbers(65, secondNum: 80)) : CGFloat(randomBetweenNumbers(5, secondNum: 25))
        return UIColor(hue: h, saturation: s, brightness: adjust / 100.0, alpha: a)
        
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
    }
    
    func createShip() {
      
        shipNode = SCNNode()
        
        shipPitchNode = SCNNode()
        shipPitchNode.rotation.x = 1
        shipRollNode = SCNNode()
        shipRollNode.rotation.z = 1
        shipYawNode = SCNNode()
        shipYawNode.rotation.y = 1
        
        shipNode.addChildNode(shipPitchNode)
        shipPitchNode.addChildNode(shipRollNode)
        shipRollNode.addChildNode(shipYawNode)
        
        
        
        // Pyramid shape
        let mainShipPyramidGeometry = SCNPyramid(width: 3.0, height: 4.0, length: 1.0)
        let mainShipPyramidMaterial = SCNMaterial()
        mainShipPyramidMaterial.diffuse.contents = UIColor.grayColor()
        mainShipPyramidGeometry.materials = [mainShipPyramidMaterial]
        let mainShipPyramidNode = SCNNode(geometry: mainShipPyramidGeometry)
        
        
        // Thruster box
        let thrusterBoxGeometry = SCNBox(width: 3.0, height: 1, length: 1, chamferRadius: 0)
        let thrusterBoxMaterial = SCNMaterial()
        thrusterBoxMaterial.diffuse.contents = UIColor.grayColor()
        thrusterBoxGeometry.materials = [thrusterBoxMaterial]
        let thrusterBoxNode = SCNNode(geometry: thrusterBoxGeometry)
        thrusterBoxNode.position.y = -0.5
        
        
        // Left Wing
        let leftWingGeometry = SCNPyramid(width: 1.0, height: 2.0, length: 1.0)
        let leftWingMaterial = SCNMaterial()
        leftWingMaterial.diffuse.contents = UIColor.grayColor()
        leftWingGeometry.materials = [leftWingMaterial]
        let leftWingNode = SCNNode(geometry: leftWingGeometry)
        leftWingNode.position.y = -0.5
        leftWingNode.position.x = -1.5
        leftWingNode.eulerAngles.z = Float(M_PI_2 )

        
        // Right Wing
        let rightWingGeometry = SCNPyramid(width: 1.0, height: 2.0, length: 1.0)
        let rightWingMaterial = SCNMaterial()
        rightWingMaterial.diffuse.contents = UIColor.grayColor()
        rightWingGeometry.materials = [rightWingMaterial]
        let rightWingNode = SCNNode(geometry: rightWingGeometry)
        rightWingNode.position.y = -0.5
        rightWingNode.position.x = 1.5
        rightWingNode.eulerAngles.z = -1 * Float(M_PI_2 )
        
        
        
        // Left torch
        let leftTorchGeometry = SCNCone(topRadius: 0.15, bottomRadius: 0.05, height: 1)
        let leftTorchMaterial = SCNMaterial()
        leftTorchMaterial.diffuse.contents = UIColor.blackColor()
        leftTorchGeometry.materials = [leftTorchMaterial]
        let leftTorchNode = SCNNode(geometry: leftTorchGeometry)
        leftTorchNode.position.y = 2
        leftTorchNode.position.x = -0.75
        

        leftTorchNode.light = SCNLight()
        leftTorchNode.light!.type = SCNLightTypeDirectional
        leftTorchNode.light!.color = UIColor.redColor()

        
        
        
        
        // Left torch
        let rightTorchGeometry = SCNCone(topRadius: 0.15, bottomRadius: 0.05, height: 1)
        let rightTorchMaterial = SCNMaterial()
        rightTorchMaterial.diffuse.contents = UIColor.blackColor()
        rightTorchGeometry.materials = [rightTorchMaterial]
        let rightTorchNode = SCNNode(geometry: rightTorchGeometry)
        rightTorchNode.position.y = 2
        rightTorchNode.position.x = 0.75

        let rightTorchLight = SCNLight()
        rightTorchLight.type = SCNLightTypeSpot
        rightTorchLight.color = UIColor.redColor()
        rightTorchLight.castsShadow = true
        rightTorchLight.attenuationEndDistance = 30
        rightTorchNode.light = rightTorchLight

        
        
        let innerShipNode = SCNNode()
        innerShipNode.addChildNode(mainShipPyramidNode)
        innerShipNode.addChildNode(thrusterBoxNode)
        innerShipNode.addChildNode(leftWingNode)
        innerShipNode.addChildNode(rightWingNode)
        innerShipNode.addChildNode(leftTorchNode)
        innerShipNode.addChildNode(rightTorchNode)
        
        
        shipYawNode.addChildNode(innerShipNode)
        
        
        
        
        // Flip the ship so it's facing forward
        innerShipNode.eulerAngles.x = BASE_SHIP_EULER_X

        
        
        unifiedCameraShipNode.addChildNode(shipNode)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .Landscape
        } else {
            return .Landscape
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}


