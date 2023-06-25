//
//  PoseView.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 23/06/23.
//

import SceneKit
import Vision

final class PoseView: SCNView {
    private var currentScene: SCNScene!
    private var cameraNode: SCNNode!
    private var lightNode: SCNNode!
    private var ambientLightNode: SCNNode!
    
    private let cameraDistance: Float = 5
    
    private var keypointNodes: [SCNNode] = []
    private var skeletonNodes: [SCNNode] = []
    
    init() {
        super.init(frame: .zero, options: nil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        currentScene = SCNScene()
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        currentScene.rootNode.addChildNode(cameraNode)
        
        lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3Make(0, 13, 9)
        currentScene.rootNode.addChildNode(lightNode)
        
        ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        currentScene.rootNode.addChildNode(ambientLightNode)
        
        scene = currentScene
        allowsCameraControl = true
        showsStatistics = true
        backgroundColor = .lightGray
        autoenablesDefaultLighting = true
        preferredFramesPerSecond = 60
        
        // This is to limit the camera rotation only to X axis
        defaultCameraController.maximumVerticalAngle = 0.001
    }
    
    func createKeypoint(_ jointPoint: JointPoint) {
        let sphere = SCNSphere(radius: 0.05)
        let keypointNode = SCNNode(geometry: sphere)
        keypointNode.position = jointPoint.point.position.positionVector3
        keypointNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
        keypointNodes.append(keypointNode)
        scene?.rootNode.addChildNode(keypointNode)
        
        if jointPoint.name == .spine {
            cameraNode.position = SCNVector3Make(jointPoint.point.position.positionVector3.x,
                                                 jointPoint.point.position.positionVector3.y,
                                                 cameraDistance)
        }
    }
    
    func removeAllKeypoints() {
        keypointNodes.forEach {
            $0.removeFromParentNode()
        }
        
        keypointNodes.removeAll()
    }
    
    func configureSkeletonNodes(_ jointPoints: [JointPoint]) {
        skeletonNodes.forEach {
            $0.removeFromParentNode()
        }
        skeletonNodes.removeAll()
        
        SkeletonType.allCases.forEach { type in
            guard
                let originKeypointVector = jointPoints.first(where: { type.originJoint == $0.name })?.point.position.positionVector3,
                let destinationKeypointVector = jointPoints.first(where: { type.endJoint == $0.name })?.point.position.positionVector3
            else {
                return
            }
            
            let vector = SCNVector3Make(originKeypointVector.x - destinationKeypointVector.x,
                                        originKeypointVector.y - destinationKeypointVector.y,
                                        originKeypointVector.z - destinationKeypointVector.z)
            let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
            let midPosition = SCNVector3Make((originKeypointVector.x + destinationKeypointVector.x) / 2,
                                             (originKeypointVector.y + destinationKeypointVector.y) / 2,
                                             (originKeypointVector.z + destinationKeypointVector.z) / 2)
            
            let line = SCNCylinder()
            line.radius = CGFloat(0.03)
            line.height = CGFloat(distance)
            line.radialSegmentCount = 5
            
            let lineNode = SCNNode(geometry: line)
            lineNode.position = midPosition
            lineNode.look(at: destinationKeypointVector,
                          up: scene!.rootNode.worldUp,
                          localFront: lineNode.worldUp)
            
            skeletonNodes.append(lineNode)
            scene?.rootNode.addChildNode(lineNode)
        }
    }
    
    func removeAllSkeletonNodes() {
        skeletonNodes.forEach {
            $0.removeFromParentNode()
        }
        
        skeletonNodes.removeAll()
    }
    
}
