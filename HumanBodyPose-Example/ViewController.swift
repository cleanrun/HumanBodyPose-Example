//
//  ViewController.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 22/06/23.
//

import UIKit
import Vision
import AVFoundation

fileprivate enum SourceType {
    case image
    case camera
    case video
    case none
}

final class ViewController: UIViewController {
    
    @IBOutlet private weak var poseViewContainerView: UIView!
    @IBOutlet private weak var sourceContainerView: UIView!
    
    private lazy var playerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private var poseView: PoseView!
    private var poseDetector = PoseDetector()
    private var cameraSession = CameraSession()
    
    private let source: SourceType = .video

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if source == .camera {
            cameraSession.startCaptureSession()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if source == .camera {
            cameraSession.stopCaptureSession()
        }
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
    
    private func setupSource() {
        if source == .image {
            // FIXME: Implement this soon, maybe add an image picker?
            return
        } else if source == .camera {
            cameraSession.delegate = self
            try? cameraSession.setupCaptureSession()
            cameraSession.setupPreviewLayer()
        } else if source == .video {
            setupPlayer()
            playerView.setupPlayerItem(runningURL)
        } else {
            poseDetector.makeRequest(using: defaultImageURL)
            renderKeypoints()
            
            if let image = UIImage(named: "man-full-body-pose") {
                sourceContainerView.layer.contents = image.cgImage
            }
        }
    }
    
    private func setupPlayer() {
        sourceContainerView.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            playerView.leftAnchor.constraint(equalTo: sourceContainerView.leftAnchor),
            playerView.rightAnchor.constraint(equalTo: sourceContainerView.rightAnchor),
            playerView.topAnchor.constraint(equalTo: sourceContainerView.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: sourceContainerView.bottomAnchor),
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
    
    private func generatedSampleBufferCallback(_ sbuf: CMSampleBuffer?) {
        guard let sbuf else { return }
        poseDetector.makeRequest(using: sbuf) { error in
            guard error == nil else {
                DispatchQueue.main.async { [unowned self] in
                    removeAllRenderedNodes()
                }
                return
            }
            
            DispatchQueue.main.async { [unowned self] in
                renderKeypoints()
            }
        }
    }
    
    private func generatedImageCallback(_ cgImage: CGImage) {
        poseDetector.makeRequest(using: cgImage) { error in
            guard error == nil else {
                DispatchQueue.main.async { [unowned self] in
                    removeAllRenderedNodes()
                }
                return
            }
            
            DispatchQueue.main.async { [unowned self] in
                renderKeypoints()
            }
        }
    }

}

extension ViewController: CameraSessionDelegate {
    func viewForPreviewLayer() -> UIView {
        sourceContainerView
    }
    
    func didOutputBuffer(_ sbuf: CMSampleBuffer) {
        generatedSampleBufferCallback(sbuf)
    }
}

extension ViewController: VideoPlayerViewDelegate {
    func didReceiveBuffer(_ sbuf: CMSampleBuffer) {
        // FIXME: Call the sample buffer callback here
    }
    
    func didReceiveImage(_ cgImage: CGImage) {
        generatedImageCallback(cgImage)
    }
}

