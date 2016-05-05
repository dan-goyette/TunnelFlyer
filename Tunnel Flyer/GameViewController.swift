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

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    let scene = SCNScene()

    
    let DRAW_DISTANCE : Float = 100.0
    let RING_VARIANCE_MIN : Float = -2.0
    let RING_VARIANCE_MAX : Float = 3.0
    let CAMERA_SPEED : Float = 15.0
    let HEX_RING_Z_INTERVAL : Float = 5
    
    var currentMaxDistance = 0
    
    var lastHexRing : [SCNVector3]? = nil
    var hexRingZ : Float = 0
    
    
    var cameraNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        cameraNode.runAction(SCNAction.repeatActionForever(SCNAction.moveByX(0, y: 0, z: CGFloat(-1 *  CAMERA_SPEED), duration: 1)))
        
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
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()

       
    }
    
    func createHexRing( z : Float) -> [SCNVector3] {
        var ring = [SCNVector3]()
        
//        ring.append(SCNVector3Make(-5 + getHexVariance(), 4 + getHexVariance(), z))
//        ring.append(SCNVector3Make(0 +  getHexVariance(), 6 + getHexVariance(), z))
//        ring.append(SCNVector3Make(5 + getHexVariance(), 4 + getHexVariance(), z))
//        ring.append(SCNVector3Make(5 + getHexVariance(), -4 + getHexVariance(), z))
//        ring.append(SCNVector3Make(0 + getHexVariance(), -6 + getHexVariance(), z))
//        ring.append(SCNVector3Make(-5 + getHexVariance(), -4 + getHexVariance(), z))
        
        
        ring.append(SCNVector3Make(-12 +  getHexVariance(), 0 + getHexVariance(), z))
        ring.append(SCNVector3Make(-8 +  getHexVariance(), 3 + getHexVariance(), z))
        ring.append(SCNVector3Make(-4 + getHexVariance(), 6 + getHexVariance(), z))
        ring.append(SCNVector3Make(0 + getHexVariance(), 9 + getHexVariance(), z))
        ring.append(SCNVector3Make(4 + getHexVariance(), 6 + getHexVariance(), z))
        ring.append(SCNVector3Make(8 + getHexVariance(), 3 + getHexVariance(), z))
        ring.append(SCNVector3Make(12 + getHexVariance(), 0 + getHexVariance(), z))
        ring.append(SCNVector3Make(8 + getHexVariance(), -3 + getHexVariance(), z))
        ring.append(SCNVector3Make(4 + getHexVariance(), -6 + getHexVariance(), z))
        ring.append(SCNVector3Make(0 + getHexVariance(), -9 + getHexVariance(), z))
        ring.append(SCNVector3Make(-4 + getHexVariance(), -6 + getHexVariance(), z))
        ring.append(SCNVector3Make(-8 +  getHexVariance(), -3 + getHexVariance(), z))


        return ring
    
    }
    
    func randomBetweenNumbers(firstNum: Float, secondNum: Float) -> Float{
        return Float(arc4random()) / Float(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        
        // If the last ring is too close, draw another ring.
        while (self.hexRingZ - cameraNode.position.z > (-1 * self.DRAW_DISTANCE) ) {
            self.addTunnelSection()
        }
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
