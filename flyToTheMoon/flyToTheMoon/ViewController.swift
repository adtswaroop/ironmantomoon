//
//  ViewController.swift
//  flyToTheMoon
//
//  Created by opal ai on 7/31/20.
//

import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubletapped))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        sceneView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer)
    {
        let touchPosition = recognizer.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchPosition, types: .featurePoint)
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else {
                return
            }
            print(hitResult.worldTransform.columns.3)
            addPlane(hitTestResults: hitResult)
            recognizer.isEnabled = false
        }
    }
    
    @objc func doubletapped(recognizer: UIGestureRecognizer){
        let touchPosition = recognizer.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchPosition, types: .featurePoint)
        guard let hitResult = hitTestResult.first else {
            return
        }
        
        let planeGeometry = SCNSphere(radius: 0.4)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "moon")
        material.ambient.contents = UIColor.white
        material.shininess = .greatestFiniteMagnitude
        material.lightingModel = .phong
        planeGeometry.materials = [material]
        
        let finishNode = SCNNode(geometry: planeGeometry)
        finishNode.name = "finish"
        finishNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(finishNode)
        if let planeNode = sceneView.scene.rootNode.childNode(withName: "plane", recursively: true) {
            rotateIronMan(to: finishNode.position, node: planeNode)
            //animatePlane(to: finishNode.position, node: planeNode)
        }
    }
    
    private func animatePlane(to destinationPt: SCNVector3, node: SCNNode){
       
    }
    
    private func rotateIronMan(to destinationPt: SCNVector3, node: SCNNode){
        let action1 = SCNAction.rotate(by: .pi/2, around: SCNVector3(0, -1, 0), duration: 5)
        node.runAction(action1){
            let action2 = SCNAction.rotate(by: .pi/2, around: SCNVector3(0, 0, 1), duration: 5)
            node.runAction(action2) {
                let action3 = SCNAction.move(to: destinationPt, duration: 7)
                node.runAction(action3) { [weak self] in
                    if let finishNode = self?.sceneView.scene.rootNode.childNode(withName: "finish", recursively: true) {
                                   finishNode.removeFromParentNode()
                               }
                }
            }
        }
//        let action = SCNAction.rotate(by: .pi/2, around: SCNVector3(0, 0, -1), duration: 5)
//        node.runAction(action) {
//        let action2 = SCNAction.move(to: destinationPt, duration: 10)
//           node.runAction(action2) { [weak self] in
//               if let finishNode = self?.sceneView.scene.rootNode.childNode(withName: "finish", recursively: true) {
//                   finishNode.removeFromParentNode()
//               }
//           }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func addPlane(hitTestResults: ARHitTestResult){
        //let scene = SCNScene(named: "art.scnassets/iron-man-2.dae")!
//        let planeNode = scene.rootNode.childNode(withName: "planeBanner", recursively: true)
//        planeNode?.name = "plane"
//        planeNode?.position = SCNVector3(hitTestResults.worldTransform.columns.3.x, hitTestResults.worldTransform.columns.3.y, hitTestResults.worldTransform.columns.3.z)
//        planeNode?.scale = .init(0.03, 0.03, 0.03)
//
//        let bannerNode = planeNode?.childNode(withName: "banner", recursively: true)
//        let bannerMaterial = bannerNode?.geometry?.materials.first(where: {$0.name == "logo" })
//        bannerMaterial?.diffuse.contents = UIImage(named: "next_reality_logo")
//        self.sceneView.scene.rootNode.addChildNode(planeNode!)
        
        guard let url = Bundle.main.url(forResource: "Iron_Man", withExtension: "usdz") else { fatalError() }
//        let mdlAsset = MDLAsset(url: url)
//        let scene = SCNScene(mdlAsset: mdlAsset)
        let scene = try! SCNScene(url: url, options: [.checkConsistency: true])
        let shipNode = SCNNode()
        let shipSceneChildNodes = scene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            shipNode.addChildNode(childNode)
        }
        shipNode.position = SCNVector3(hitTestResults.worldTransform.columns.3.x, hitTestResults.worldTransform.columns.3.y, hitTestResults.worldTransform.columns.3.z)
        shipNode.scale = .init(0.004, 0.004, 0.004)
        shipNode.light = SCNLight()
        shipNode.light?.type = .directional
        sceneView.autoenablesDefaultLighting = true
        shipNode.name = "plane"
        self.sceneView.scene.rootNode.addChildNode(shipNode)
    }
}
