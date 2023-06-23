//
//  SkeletonType.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 23/06/23.
//

import Foundation
import Vision

enum SkeletonType: CaseIterable {
    case topHeadToCenterHead
    case centerHeadToCenterShoulder
    
    case centerShoulderToLeftShoulder
    case centerShoulderToRightShoulder
    case centerShoulderToSpine
    
    case leftShoulderToLeftElbow
    case leftElbowToLeftWrist
    
    case rightShoulderToRightElbow
    case rightElbowToRightWrist
    
    case spineToRoot
    
    case rootToLeftHip
    case rootToRightHip
    
    case leftHipToLeftKnee
    case leftKneeToLeftAnkle
    
    case rightHipToRightKnee
    case rightKneeToRightAnkle
    
    var originJoint: JointName {
        switch self {
        case .topHeadToCenterHead:
            return .topHead
        case .centerHeadToCenterShoulder:
            return .centerHead
        case .centerShoulderToLeftShoulder, .centerShoulderToRightShoulder, .centerShoulderToSpine:
            return .centerShoulder
        case .leftShoulderToLeftElbow:
            return .leftShoulder
        case .leftElbowToLeftWrist:
            return .leftElbow
        case .rightShoulderToRightElbow:
            return .rightShoulder
        case .rightElbowToRightWrist:
            return .rightElbow
        case .spineToRoot:
            return .spine
        case .rootToLeftHip, .rootToRightHip:
            return .root
        case .leftHipToLeftKnee:
            return .leftHip
        case .leftKneeToLeftAnkle:
            return .leftKnee
        case .rightHipToRightKnee:
            return .rightHip
        case .rightKneeToRightAnkle:
            return .rightKnee
        }
    }
    
    var endJoint: JointName {
        switch self {
        case .topHeadToCenterHead:
            return .centerHead
        case .centerHeadToCenterShoulder:
            return .centerShoulder
        case .centerShoulderToLeftShoulder:
            return .leftShoulder
        case .centerShoulderToRightShoulder:
            return .rightShoulder
        case .centerShoulderToSpine:
            return .spine
        case .leftShoulderToLeftElbow:
            return .leftElbow
        case .leftElbowToLeftWrist:
            return .leftWrist
        case .rightShoulderToRightElbow:
            return .rightElbow
        case .rightElbowToRightWrist:
            return .rightWrist
        case .spineToRoot:
            return .root
        case .rootToLeftHip:
            return .leftHip
        case .rootToRightHip:
            return .rightHip
        case .leftHipToLeftKnee:
            return .leftKnee
        case .leftKneeToLeftAnkle:
            return .leftAnkle
        case .rightHipToRightKnee:
            return .rightKnee
        case .rightKneeToRightAnkle:
            return .rightAnkle
        }
    }
}
