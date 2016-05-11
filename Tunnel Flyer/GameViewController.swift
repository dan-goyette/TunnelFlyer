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
    let RING_VARIANCE_MIN : Float = -2.0
    let RING_VARIANCE_MAX : Float = 3.0
    let CAMERA_SPEED : Float = 0.25
    let HEX_RING_Z_INTERVAL : Float = 5
    let SHIP_MOVEMENT_SPEED : Float = 0.5
    let SHIP_PITCH_INTERVAL : Float = 0.50
    let SHIP_ROLL_INTERVAL : Float = 0.04
    let BASE_SHIP_EULER_X : Float = -1 * Float(M_PI_2)
    
    var currentMaxDistance = 0
    
    var lastHexRing : [SCNVector3]? = nil
    var hexRingZ : Float = 0
    var shipNode : SCNNode!
    var shipPitchNode: SCNNode!
    var shipRollNode: SCNNode!
    var shipYawNode: SCNNode!
    
    var unifiedCameraShipNode : SCNNode!
    var unifiedPitchNode: SCNNode!
    var unifiedRollNode: SCNNode!
    var unifiedYawNode: SCNNode!
    var unifiedInnerNode: SCNNode!
    
    
    var cameraNode = SCNNode()
    
    var shipRoll : Float = 0
    var shipPitch : Float = 0
    
    var joystickValues : JoystickValues = JoystickValues()
    
    
    var hudScene :  SKScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unifiedCameraShipNode = SCNNode()
        unifiedCameraShipNode.position = SCNVector3(x: 0, y: 0, z: 0)
        unifiedPitchNode = SCNNode()
        unifiedPitchNode.rotation.x = 1
        unifiedRollNode = SCNNode()
        unifiedRollNode.rotation.z = 1
        unifiedYawNode = SCNNode()
        unifiedYawNode.rotation.y = 1
        unifiedInnerNode = SCNNode()
        
        unifiedCameraShipNode.addChildNode(unifiedPitchNode)
        unifiedPitchNode.addChildNode(unifiedRollNode)
        unifiedRollNode.addChildNode(unifiedYawNode)
        unifiedYawNode.addChildNode(unifiedInnerNode)
     
        
        
        // Create ship
        createShip()
     
        
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        // Relative to the unified camera ship, the camera is 15z closer to the viewer.
        cameraNode.position = SCNVector3(x: 0, y: 4, z: 15)
        
        let cameraConstraint = SCNLookAtConstraint(target: shipNode)
        cameraConstraint.gimbalLockEnabled = true
        cameraNode.constraints = [cameraConstraint]
        
        unifiedInnerNode.addChildNode(cameraNode)
        
        
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
        
        //scnView.autoenablesDefaultLighting = false
        
        // Enter render loop at every frame.
        scnView.playing = true;
        
        // prevents the user from manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()

        
        
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
        

        
        ring.append(SCNVector3Make(-24 +  getHexVariance(), 0 + getHexVariance(), z))
        ring.append(SCNVector3Make(-16 +  getHexVariance(), 6 + getHexVariance(), z))
        ring.append(SCNVector3Make(-8 + getHexVariance(), 12 + getHexVariance(), z))
        ring.append(SCNVector3Make(0 + getHexVariance(), 18 + getHexVariance(), z))
        ring.append(SCNVector3Make(8 + getHexVariance(), 12 + getHexVariance(), z))
        ring.append(SCNVector3Make(16 + getHexVariance(), 6 + getHexVariance(), z))
        ring.append(SCNVector3Make(24 + getHexVariance(), 0 + getHexVariance(), z))
        ring.append(SCNVector3Make(16 + getHexVariance(), -6 + getHexVariance(), z))
        ring.append(SCNVector3Make(8 + getHexVariance(), -12 + getHexVariance(), z))
        ring.append(SCNVector3Make(0 + getHexVariance(), -18 + getHexVariance(), z))
        ring.append(SCNVector3Make(-8 + getHexVariance(), -12 + getHexVariance(), z))
        ring.append(SCNVector3Make(-16 +  getHexVariance(), -6 + getHexVariance(), z))


        return ring
    
    }
    
    func randomBetweenNumbers(firstNum: Float, secondNum: Float) -> Float{
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        // If the last ring is too close, draw another ring.
        while (self.hexRingZ - unifiedCameraShipNode.position.z > (-1 * self.DRAW_DISTANCE) ) {
            self.addTunnelSection()
        }
        
        unifiedCameraShipNode.position.z -= CAMERA_SPEED
      

        shipRoll = -1.0 * (joystickValues.leftJoystickValue - joystickValues.rightJoystickValue) * SHIP_ROLL_INTERVAL
        shipPitch =  -1.0 * (joystickValues.leftJoystickValue + joystickValues.rightJoystickValue) * SHIP_PITCH_INTERVAL
        
        unifiedRollNode.rotation.w += shipRoll
        
        let liftX = sin( unifiedRollNode.rotation.w ) * shipPitch * SHIP_MOVEMENT_SPEED * -1
        let liftY = cos( unifiedRollNode.rotation.w ) * shipPitch * SHIP_MOVEMENT_SPEED
        
        
    
        
        unifiedCameraShipNode.position.x += liftX
        unifiedCameraShipNode.position.y += liftY
        
        
        
        let gameStats = GameStats()
        gameStats.shipRoll = unifiedRollNode.rotation.w
        gameStats.shipPitch = unifiedPitchNode.rotation.w
        gameStats.shipX = unifiedCameraShipNode.position.x
        gameStats.shipY = unifiedCameraShipNode.position.y
        gameStats.shipZ = unifiedCameraShipNode.position.z
        
        gameStats.shipEulerX = unifiedCameraShipNode.eulerAngles.x
        gameStats.shipEulerY = unifiedCameraShipNode.eulerAngles.y
        gameStats.shipEulerZ = unifiedCameraShipNode.eulerAngles.z
        
        gameStats.liftX = liftX
        gameStats.liftY = liftY
        
        shipPitchNode.rotation.w = shipPitch / 3.0
        shipRollNode.rotation.w = shipRoll * 3.0
        
        
        NSNotificationCenter.defaultCenter().postNotificationName(gameStatsUpdatedNotificationKey, object: nil, userInfo:["gameStats": gameStats])

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
        material.diffuse.contents = getRandomColor()
        

        
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

        
        
        unifiedYawNode.addChildNode(shipNode)
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


