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

    
    let DRAW_DISTANCE : Float = 200.0
    let RING_SIZE_MULTIPLIER : Float = 20
    let RING_VARIANCE_MIN : Float = -8.0
    let RING_VARIANCE_MAX : Float = 8.0
    let CAMERA_SPEED : Float = 0.35
    let HEX_RING_Z_INTERVAL : Float = 10
    let SHIP_MOVEMENT_SPEED : Float = 200.0
    let SHIP_TERMINAL_SPEED : Float = 100.0
    let SHIP_PITCH_INTERVAL : Float = 20.35
    let SHIP_ROLL_INTERVAL : Float = 20.35
    let SHIP_YAW_INTERVAL : Float = 20.35
    let BASE_SHIP_EULER_X : Float = -1 * Float(M_PI_2)
    
    
    var currentMaxDistance = 0
    
    var lastHexRing : [SCNVector3]? = nil
    var hexRingZ : Float = 0
    var shipNode : SCNNode!
    var shipPitchNode: SCNNode!
    var shipRollNode: SCNNode!
    var shipYawNode: SCNNode!
    
    var tunnelNodes : [NodePositionReference] = [NodePositionReference]()
    
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
        let unifiedPhysicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(geometry: SCNBox(width: 2, height: 1, length: 3, chamferRadius: 0), options: nil))
        unifiedPhysicsBody.angularDamping = 0.999
        unifiedPhysicsBody.damping = 0.5
        unifiedPhysicsBody.mass = 1
        unifiedPhysicsBody.affectedByGravity = false
        unifiedPhysicsBody.categoryBitMask = CollisionBitmasks.Ship
        unifiedPhysicsBody.collisionBitMask = CollisionBitmasks.Asteroids | CollisionBitmasks.Walls
        unifiedCameraShipNode.physicsBody = unifiedPhysicsBody
        
        // Create ship
        createShip()
        
       
     
        
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.zFar = 200
        // Relative to the unified camera ship, the camera is 15z closer to the viewer.
        cameraNode.position = SCNVector3(x: 0, y: 4, z: 15)
        
        let cameraConstraint = SCNLookAtConstraint(target: shipNode)
        cameraConstraint.gimbalLockEnabled = true
        cameraNode.constraints = [cameraConstraint]
        
        unifiedCameraShipNode.addChildNode(cameraNode)
        
        
        scene.rootNode.addChildNode(unifiedCameraShipNode)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 0)
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

        scnView.debugOptions = .ShowPhysicsShapes
        //scnView.debugOptions = .ShowLightExtents
        
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
            
            // Good time to remove old sections that aren't needed anymore.
            // Remove any that are more than 2X DrawDistance behind the current ring's Z.

            let maxDistance =  2 * self.DRAW_DISTANCE
            if (tunnelNodes.count > 0) {
                for i in (0...(tunnelNodes.count - 1)).reverse() {
                    if (getDistance(unifiedCameraShipNode.presentationNode.position, position2: tunnelNodes[i].position) > maxDistance) {
                        tunnelNodes[i].node.removeFromParentNode()
                        tunnelNodes.removeAtIndex(i)
                    }
                }
            }
            
            if (self.hexRingZ % 25 == 0) {
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
        shipPitchNode.rotation.w = -1 * joystickValues.leftJoystickYValue / 2.0
        shipRollNode.rotation.w = -1 * joystickValues.rightJoystickXValue / 2.0
        shipYawNode.rotation.w = -1 * joystickValues.leftJoystickXValue / 2.0
        
        

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
        
        
        
//        let gameStats = GameStats()
//        gameStats.shipX = unifiedCameraShipNode.position.x
//        gameStats.shipY = unifiedCameraShipNode.position.y
//        gameStats.shipZ = unifiedCameraShipNode.position.z
//        
//        gameStats.shipEulerX = unifiedCameraShipNode.eulerAngles.x
//        gameStats.shipEulerY = unifiedCameraShipNode.eulerAngles.y
//        gameStats.shipEulerZ = unifiedCameraShipNode.eulerAngles.z
        
        
        //NSNotificationCenter.defaultCenter().postNotificationName(gameStatsUpdatedNotificationKey, object: nil, userInfo:["gameStats": gameStats])

    }
    
    func exaggerate(value : Float) -> Float {
        return powf(value, 3)// * getSign(value)
    }

    func getSign(value : Float) -> Float {
        return value < 0 ? -1 : 1
    }
    
    func getDistance(position1 : SCNVector3, position2: SCNVector3) -> Float {
        return GLKVector3Distance(SCNVector3ToGLKVector3(position1), SCNVector3ToGLKVector3(position2))
    }
    
    func applyRotationToVector(rotation : SCNVector4, vector: SCNVector3) -> SCNVector3 {
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let glkMatrix = SCNMatrix4ToGLKMatrix4(rotationMatrix)
        let glkVector = SCNVector3ToGLKVector3(vector)
        let resultVector = GLKMatrix4MultiplyVector3(glkMatrix, glkVector)
        return SCNVector3FromGLKVector3(resultVector)
    }
    
    func createDebris() {
        
        let cube = SCNBox(width: 6, height: 6, length: 6, chamferRadius: 2.5)
        
        let material = SCNMaterial()
        //material.doubleSided = true
        material.diffuse.contents = getRandomColor()
        
        cube.materials = [material]
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position.z = self.hexRingZ
        
        cubeNode.position.x = randomBetweenNumbers( -1 * RING_SIZE_MULTIPLIER, secondNum: RING_SIZE_MULTIPLIER)
        cubeNode.position.y = randomBetweenNumbers( -1 * RING_SIZE_MULTIPLIER, secondNum: RING_SIZE_MULTIPLIER)
        cubeNode.position.z = self.hexRingZ

        
        let rotate = SCNAction.rotateByX(2.1, y: 0.3, z: 1.1, duration: 1.0)
        let rotateLoop = SCNAction.repeatActionForever(rotate)
        cubeNode.runAction(rotateLoop)
        
        let move = SCNAction.moveByX(CGFloat(randomBetweenNumbers( -3.0, secondNum: 3.0)), y: CGFloat(randomBetweenNumbers( -3.0, secondNum: 3.0)), z: CGFloat(randomBetweenNumbers( -3.0, secondNum: 3.0)), duration: 1)
        let moveLoop = SCNAction.repeatActionForever(move)
        cubeNode.runAction(moveLoop)
        
        
        cubeNode.physicsBody = SCNPhysicsBody(type: .Dynamic, shape: SCNPhysicsShape(node: cubeNode, options: nil))
        cubeNode.physicsBody!.affectedByGravity = false
        cubeNode.physicsBody!.categoryBitMask = CollisionBitmasks.Asteroids
        cubeNode.physicsBody!.collisionBitMask = CollisionBitmasks.Ship | CollisionBitmasks.Walls
        

        
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
    
    
    
    
    func addTriangleFromPositions(scene: SCNScene, point1: SCNVector3, point2: SCNVector3, point3: SCNVector3)
    {
        let vector12 = GLKVector3Make(point1.x - point2.x, point1.y - point2.y, point1.z - point2.z)
        let vector32 = GLKVector3Make(point3.x - point2.x, point3.y - point2.y, point3.z - point2.z)
        let normalVector = SCNVector3FromGLKVector3(GLKVector3CrossProduct(vector12, vector32))
        
        
        let positions: [SCNVector3] = [point1, point2, point3]
        let normals: [SCNVector3] = [normalVector, normalVector, normalVector]
        let indices: [Int32] = [0, 2, 1]
        let vertexSource = SCNGeometrySource(vertices: positions, count: positions.count)
        let normalSource = SCNGeometrySource(normals: normals, count: normals.count)
        let indexData = NSData(bytes: indices, length: sizeof(Int32) * indices.count)
        
        let element = SCNGeometryElement(data: indexData, primitiveType: .Triangles, primitiveCount: indices.count, bytesPerIndex: sizeof(Int32))
        //let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        let shape = SCNShape(sources: [vertexSource, normalSource], elements: [element])
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 101.0 / 256.0, green: 16.0 / 256.0, blue: 0, alpha: 1 )
        
        shape.materials = [material]
        let shapeNode = SCNNode(geometry: shape)
        
//        let physicsBody = SCNPhysicsBody(type: .Kinematic, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 2, length: 3, chamferRadius: 0), options: nil))
//        shapeNode.physicsBody = physicsBody
        
        
        
        scene.rootNode.addChildNode(shapeNode)
    }
    
    func getHexVariance() -> Float {
        return randomBetweenNumbers( self.RING_VARIANCE_MIN, secondNum: self.RING_VARIANCE_MAX)
    }
    
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        var x = 0
    }
    
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func getRandomShadeOfColor(color : UIColor, lighter : Bool = true) -> UIColor {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var l : CGFloat = 0
        var a : CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &l, alpha: &a)
        
        
        let adjust = lighter ? CGFloat(randomBetweenNumbers(65, secondNum: 80)) : CGFloat(randomBetweenNumbers(5, secondNum: 25))
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
        
        
        // Left Globe Node
//        let leftGlobeNodeGeometry = SCNSphere(radius: 0.15)
//        let leftGlobeNodeMaterial = SCNMaterial()
//        leftGlobeNodeMaterial.emission.contents = UIColor.cyanColor()
//        leftGlobeNodeGeometry.materials = [leftGlobeNodeMaterial]
//        let leftGlobeNode = SCNNode(geometry: leftGlobeNodeGeometry)
//        leftGlobeNode.position = SCNVector3Make(0, 2, 0)
//        let leftGlobeLight = SCNLight()
//        leftGlobeLight.type = SCNLightTypeOmni
//        leftGlobeLight.color = UIColor.cyanColor()
//        leftGlobeLight.attenuationStartDistance = 80
//        leftGlobeLight.attenuationEndDistance = 120
//        leftGlobeNode.light = leftGlobeLight
//        leftGlobeNode.eulerAngles.x = Float(M_PI_2)
//        leftGlobeNode.eulerAngles.z = Float( -1 * M_PI_4)
//        leftWingNode.addChildNode(leftGlobeNode)

        

        
        // Right Wing
        let rightWingGeometry = SCNPyramid(width: 1.0, height: 2.0, length: 1.0)
        let rightWingMaterial = SCNMaterial()
        rightWingMaterial.diffuse.contents = UIColor.grayColor()
        rightWingGeometry.materials = [rightWingMaterial]
        let rightWingNode = SCNNode(geometry: rightWingGeometry)
        rightWingNode.position.y = -0.5
        rightWingNode.position.x = 1.5
        rightWingNode.eulerAngles.z = -1 * Float(M_PI_2 )
        
        
        
        // right Globe Node
//        let rightGlobeNodeGeometry = SCNSphere(radius: 0.15)
//        let rightGlobeNodeMaterial = SCNMaterial()
//        rightGlobeNodeMaterial.emission.contents = UIColor.cyanColor()
//        rightGlobeNodeGeometry.materials = [rightGlobeNodeMaterial]
//        let rightGlobeNode = SCNNode(geometry: rightGlobeNodeGeometry)
//        rightGlobeNode.position = SCNVector3Make(0, 2, 0)
//        let rightGlobeLight = SCNLight()
//        rightGlobeLight.type = SCNLightTypeOmni
//        rightGlobeLight.color = UIColor.cyanColor()
//        rightGlobeLight.attenuationStartDistance = 80
//        rightGlobeLight.attenuationEndDistance = 120
//        rightGlobeNode.light = rightGlobeLight
//        
//        rightGlobeNode.eulerAngles.x = Float( M_PI_2)
//        rightGlobeNode.eulerAngles.z = Float( M_PI_4)
//        rightWingNode.addChildNode(rightGlobeNode)

        
        
        
        // Left torch
        let leftTorchGeometry = SCNCone(topRadius: 0.15, bottomRadius: 0.05, height: 1)
        let leftTorchMaterial = SCNMaterial()
        leftTorchMaterial.diffuse.contents = UIColor.darkGrayColor()
        leftTorchGeometry.materials = [leftTorchMaterial]
        let leftTorchNode = SCNNode(geometry: leftTorchGeometry)
        leftTorchNode.position.y = 2
        leftTorchNode.position.x = 0
        leftTorchNode.position.z = 0.2
        //leftTorchNode.eulerAngles.x = Float(M_PI_4)
        
        let leftTorchLightNode = SCNNode()
        let leftTorchLight = SCNLight()
        leftTorchLight.type = SCNLightTypeSpot
        leftTorchLight.spotInnerAngle = 15.0
        leftTorchLight.spotOuterAngle = 60.0
        leftTorchLight.castsShadow = false
        //leftTorchLight.color = UIColor(white: 0.5, alpha: 0.5)
        leftTorchLightNode.eulerAngles.x = Float(M_PI_2)
        //leftTorchLightNode.light = leftTorchLight
        leftTorchNode.addChildNode(leftTorchLightNode)
        
//        
//        // Right torch
//        let rightTorchGeometry = SCNCone(topRadius: 0.15, bottomRadius: 0.05, height: 1)
//        let rightTorchMaterial = SCNMaterial()
//        rightTorchMaterial.diffuse.contents = UIColor.blackColor()
//        rightTorchGeometry.materials = [rightTorchMaterial]
//        let rightTorchNode = SCNNode(geometry: rightTorchGeometry)
//        rightTorchNode.position.y = 2
//        rightTorchNode.position.x = 0.75
//        //rightTorchNode.eulerAngles.x = Float(M_PI_4)
//        
//        let rightTorchLight = SCNLight()
//        rightTorchLight.type = SCNLightTypeSpot
//        rightTorchLight.spotInnerAngle = 15.0
//        rightTorchLight.spotOuterAngle = 60.0
//        rightTorchLight.castsShadow = false
//        //rightTorchLight.color =  UIColor(white: 0.5, alpha: 0.5)
//        rightTorchNode.light = rightTorchLight

        
        
        
        
        let globeNode = SCNNode( )
        globeNode.position = SCNVector3Make(0, -4, 2)
        let globeLight = SCNLight()
        globeLight.type = SCNLightTypeOmni
        globeLight.color = UIColor.cyanColor()
        globeLight.attenuationStartDistance = 80
        globeLight.attenuationEndDistance = 160
        globeLight.attenuationFalloffExponent = 1
        globeNode.light = globeLight
        
        
        
        
        // Inner Node, contains all the ship parts.
        let innerShipNode = SCNNode()
        innerShipNode.addChildNode(mainShipPyramidNode)
        innerShipNode.addChildNode(thrusterBoxNode)
        innerShipNode.addChildNode(leftWingNode)
        innerShipNode.addChildNode(rightWingNode)
        innerShipNode.addChildNode(leftTorchNode)
        //innerShipNode.addChildNode(rightTorchNode)
        //innerShipNode.addChildNode(globeNode)

        
        
        shipYawNode.addChildNode(innerShipNode)
        
        
        
        
        // Flip the ship so it's facing forward
        innerShipNode.eulerAngles.x = BASE_SHIP_EULER_X
        
        
        
        
//        let spotLight = SCNLight()
//        spotLight.type = SCNLightTypeSpot
//        spotLight.spotInnerAngle = 15.0
//        spotLight.spotOuterAngle = 60.0
//        spotLight.castsShadow = true
//        let spotLightNode = SCNNode()
//        spotLightNode.light = spotLight
//        spotLightNode.position = SCNVector3(1.5, 1.5, 1.5)
//
//        shipNode.addChildNode(spotLightNode)
        
       

        
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


