//
//  ViewController.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 22/06/23.
//

import UIKit
import Vision
import CoreMedia

final class ViewController: UIViewController {
    
    @IBOutlet weak var poseViewContainerView: UIView!
    @IBOutlet weak var cameraContainerView: UIView!
    
    private var poseView: PoseView!
    private var poseDetector = PoseDetector()
    private var cameraSession = CameraSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraSession.delegate = self
        try? cameraSession.setupCaptureSession()
        cameraSession.setupPreviewLayer()
        
//        poseDetector.makeRequest(using: Bundle.main.url(forResource: "man-full-body-pose", withExtension: "png")!)
//        renderKeypoints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraSession.startCaptureSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraSession.stopCaptureSession()
    }
    
    override func loadView() {
        super.loadView()
        
        poseView = PoseView()
        poseView.translatesAutoresizingMaskIntoConstraints = false
        poseViewContainerView.addSubview(poseView)
        
        NSLayoutConstraint.activate([
            poseView.leftAnchor.constraint(equalTo: poseViewContainerView.leftAnchor),
            poseView.rightAnchor.constraint(equalTo: poseViewContainerView.rightAnchor),
            poseView.topAnchor.constraint(equalTo: poseViewContainerView.safeAreaLayoutGuide.topAnchor),
            poseView.bottomAnchor.constraint(equalTo: poseViewContainerView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func renderKeypoints() {
        poseView.removeAllKeypoints()
        
        for jointPoint in poseDetector.recognizedPoints {
            poseView.createKeypoint(jointPoint)
        }
        
        poseView.configureSkeletonNodes(poseDetector.recognizedPoints)
    }
    
    private func removeAllRenderedNodes() {
        poseView.removeAllKeypoints()
        poseView.removeAllSkeletonNodes()
    }

}

extension ViewController: CameraSessionDelegate {
    func viewForPreviewLayer() -> UIView {
        cameraContainerView
    }
    
    func didOutputBuffer(_ sbuf: CMSampleBuffer) {
        poseDetector.makeRequest(using: sbuf) { error in
            guard error == nil else {
                removeAllRenderedNodes()
                return
            }
            
            renderKeypoints()
        }
    }
    
}

