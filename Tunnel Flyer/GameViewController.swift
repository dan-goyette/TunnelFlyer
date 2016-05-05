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
        
        
        for i in 0...(hexArrays.count - 2) {
            let ring1 = hexArrays[i]
            let ring2 = hexArrays[i + 1]
            
            for j in 0...(ring1.count - 1) {
                let triangle1Point1 = ring1[j % ring1.count]
                let triangle1Point2 = ring1[(j + 1) % ring1.count]
                let triangle1Point3 = ring2[j % ring1.count]
                
                addTriangleFromPoints(scene, point1: triangle1Point1, point2: triangle1Point2, point3: triangle1Point3)
                
                let triangle2Point1 = ring1[(j + 1) % ring1.count]
                let triangle2Point2 = ring2[(j + 1) % ring1.count]
                let triangle2Point3 = ring2[j % ring1.count]
                
                addTriangleFromPoints(scene, point1: triangle2Point1, point2: triangle2Point2, point3: triangle2Point3)

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
        shapeNode.position = SCNVector3(x: 0, y: 0, z: 0);
        scene.rootNode.addChildNode(shapeNode)
        shapeNode.rotation = SCNVector4(x: -1.0, y: -1.0, z: 5.0, w: 0.0)
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
