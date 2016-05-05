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

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        //cameraNode.runAction(SCNAction.repeatActionForever(SCNAction.moveByX(0, y: 0, z: -2, duration: 1)))
        
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
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()

        
        
        
        
        
        // Add some hexagons
        
        
        
        
        
        var hexArrays = [[SCNVector3]]()
        
        
        
        var ring1Points = [SCNVector3]()
        ring1Points.append(SCNVector3Make(-5, 4, 0))
        ring1Points.append(SCNVector3Make(0, 6, 0))
        ring1Points.append(SCNVector3Make(5, 4, 0))
        ring1Points.append(SCNVector3Make(5, -4, 0))
        ring1Points.append(SCNVector3Make(0, -6, 0))
        ring1Points.append(SCNVector3Make(-5, -4, 0))
        hexArrays.append(ring1Points)
        
        var ring2Points = [SCNVector3]()
        ring2Points.append(SCNVector3Make(-5, 4.4, -5))
        ring2Points.append(SCNVector3Make(0.8, 6.1, -5))
        ring2Points.append(SCNVector3Make(5, 4, -5))
        ring2Points.append(SCNVector3Make(5, -4.1, -5))
        ring2Points.append(SCNVector3Make(0.4, -6.4, -5))
        ring2Points.append(SCNVector3Make(-5, -4, -5))
        hexArrays.append(ring2Points)
        
        var ring3Points = [SCNVector3]()
        ring3Points.append(SCNVector3Make(-5, 4, -10))
        ring3Points.append(SCNVector3Make(0, 6, -10))
        ring3Points.append(SCNVector3Make(5, 4, -10))
        ring3Points.append(SCNVector3Make(5, -4, -10))
        ring3Points.append(SCNVector3Make(0, -6, -10))
        ring3Points.append(SCNVector3Make(-5, -4, -10))
        hexArrays.append(ring3Points)
        
        
        var ring4Points = [SCNVector3]()
        ring4Points.append(SCNVector3Make(-5, 4.4, -15))
        ring4Points.append(SCNVector3Make(0.8, 6.1, -15))
        ring4Points.append(SCNVector3Make(5, 4, -15))
        ring4Points.append(SCNVector3Make(5, -4.1, -15))
        ring4Points.append(SCNVector3Make(0.4, -6.4, -15))
        ring4Points.append(SCNVector3Make(-5, -4, -15))
        hexArrays.append(ring4Points)

        
        
        for i in 0...(hexArrays.count - 2) {
            let ring1 = hexArrays[i]
            let ring2 = hexArrays[i + 1]
            
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
        
       
    }
    
    func addTriangleFromPoints(scene: SCNScene, point1: SCNVector3, point2: SCNVector3, point3: SCNVector3) {
        
        
        let material = SCNMaterial()
        material.doubleSided = true
        material.diffuse.contents = getRandomColor()
        
        
        
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(CGPointMake(CGFloat(point1.x), CGFloat(point1.y)))
        bezierPath.addLineToPoint(CGPointMake(CGFloat(point2.x), CGFloat(point2.y)))
        bezierPath.addLineToPoint(CGPointMake(CGFloat(point3.x), CGFloat(point3.y)))
        bezierPath.closePath()
        
        
        let shape = SCNShape(path: bezierPath, extrusionDepth: 0)
        shape.materials = [material]
        let shapeNode = SCNNode(geometry: shape)
        shapeNode.position = SCNVector3(x: 0, y: 0, z: point1.z);
        scene.rootNode.addChildNode(shapeNode)
        shapeNode.rotation = SCNVector4(x: 90, y: 90.0, z: 90, w: 0.0)
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
