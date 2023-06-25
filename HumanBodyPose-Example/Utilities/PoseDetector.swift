//
//  PoseDetector.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 22/06/23.
//

import Foundation
import Vision

typealias RecognizedPointsGroup = [VNHumanBodyPose3DObservation.JointName : VNHumanBodyRecognizedPoint3D]
typealias RecognizedPoint = VNHumanBodyRecognizedPoint3D
typealias JointName = VNHumanBodyPose3DObservation.JointName

final class PoseDetector {
    
    private var request: VNDetectHumanBodyPose3DRequest
    private var bodyObservation: VNHumanBodyPose3DObservation?
    private(set) var recognizedPoints: [JointPoint] = []
    
    private let keypointNames: [JointName] = [
        .root,
        .rightHip,
        .rightKnee,
        .rightAnkle,
        .leftHip,
        .leftKnee,
        .leftAnkle,
        .spine,
        .centerShoulder,
        .centerHead,
        .topHead,
        .leftShoulder,
        .leftElbow,
        .leftWrist,
        .rightShoulder,
        .rightElbow,
        .rightWrist,
    ]
    
    init() {
        request = VNDetectHumanBodyPose3DRequest()
    }
    
    func makeRequest(using imageURL: URL) {
        recognizedPoints.removeAll()

        let imageRequest = VNImageRequestHandler(url: imageURL)
        do {
            try imageRequest.perform([request])
            if let performedObservations = request.results?.first {
                bodyObservation = performedObservations
                for keypointName in keypointNames {
                    if let point = getPoint(keypointName) {
                        let jointPoint = JointPoint(name: keypointName, point: point)
                        recognizedPoints.append(jointPoint)
                    }
                }
            }
        } catch {
            print("Perform request error: \(error.localizedDescription)")
        }
    }
    
    func makeRequest(using sbuf: CMSampleBuffer, completion: (PoseRequestError?) -> Void) {
        recognizedPoints.removeAll()
        
        let bufferRequest = VNImageRequestHandler(cmSampleBuffer: sbuf)
        do {
            try bufferRequest.perform([request])
            if let performedObservations = request.results?.first {
                bodyObservation = performedObservations
                for keypointName in keypointNames {
                    if let point = getPoint(keypointName) {
                        let jointPoint = JointPoint(name: keypointName, point: point)
                        recognizedPoints.append(jointPoint)
                    }
                }
                completion(nil)
            } else {
                completion(.observationIsNil)
            }
        } catch {
            print("Perform request error: \(error.localizedDescription)")
            completion(.failedToPerformTheRequest)
        }
    }
    
    func makeRequest(using image: CGImage, completion: (PoseRequestError?) -> Void) {
        recognizedPoints.removeAll()
        
        let bufferRequest = VNImageRequestHandler(cgImage: image)
        do {
            try bufferRequest.perform([request])
            if let performedObservations = request.results?.first {
                bodyObservation = performedObservations
                for keypointName in keypointNames {
                    if let point = getPoint(keypointName) {
                        let jointPoint = JointPoint(name: keypointName, point: point)
                        recognizedPoints.append(jointPoint)
                    }
                }
                completion(nil)
            } else {
                completion(.observationIsNil)
            }
        } catch {
            print("Perform request error: \(error.localizedDescription)")
            completion(.failedToPerformTheRequest)
        }
    }
    
    private func getPointsGroup(_ group: VNHumanBodyPose3DObservation.JointsGroupName) -> RecognizedPointsGroup? {
        if let bodyObservation {
            return try? bodyObservation.recognizedPoints(group)
        }
        
        return nil
    }
    
    private func getPoint(_ point: VNHumanBodyPose3DObservation.JointName) -> RecognizedPoint? {
        if let bodyObservation {
            return try? bodyObservation.recognizedPoint(point)
        }
        
        return nil
    }
}
