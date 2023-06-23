//
//  CameraSession.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 23/06/23.
//

import UIKit
import AVFoundation

protocol CameraSessionDelegate: AnyObject {
    func viewForPreviewLayer() -> UIView
    func didOutputBuffer(_ sbuf: CMSampleBuffer)
}

final class CameraSession: NSObject {
    
    weak var delegate: CameraSessionDelegate?
    
    private var captureSession: AVCaptureSession!
    private var captureDevice: AVCaptureDevice!
    private var captureVideoDataOutput: AVCaptureVideoDataOutput!
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let captureQueue = DispatchQueue(label: "capture-queue", qos: .userInitiated)
    
    func setupCaptureSession() throws {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1280x720
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices
        
        guard let videoCaptureDevice = devices.first else {
            throw AVError(.decoderTemporarilyUnavailable)
        }
        
        captureDevice = videoCaptureDevice
        
        let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            throw AVError(.operationNotAllowed)
        }
        
        captureVideoDataOutput = AVCaptureVideoDataOutput()
        captureVideoDataOutput.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA) ]
        
        if captureSession.canAddOutput(captureVideoDataOutput) {
            DispatchQueue.main.async { [unowned self] in
                self.captureSession.addOutput(captureVideoDataOutput)
            }
            captureVideoDataOutput.setSampleBufferDelegate(self, queue: captureQueue)
            captureVideoDataOutput.alwaysDiscardsLateVideoFrames = true
        }
        
        captureSession.beginConfiguration()
        try videoCaptureDevice.lockForConfiguration()
        videoCaptureDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(10))
        videoCaptureDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(10))
        videoCaptureDevice.unlockForConfiguration()
        captureSession.commitConfiguration()
    }
    
    func setupPreviewLayer() {
        guard let delegate else { return }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //previewLayer.connection?.videoOrientation = .portraitUpsideDown
        //previewLayer.videoGravity = .resizeAspectFill
        DispatchQueue.main.async { [unowned self] in
            self.previewLayer.frame = delegate.viewForPreviewLayer().bounds
            delegate.viewForPreviewLayer().layer.addSublayer(self.previewLayer)
        }
    }
    
    func startCaptureSession() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopCaptureSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

extension CameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.didOutputBuffer(sampleBuffer)
    }
}
