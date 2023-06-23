//
//  PoseRequestError.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 23/06/23.
//

import Foundation

enum PoseRequestError: Error {
    case failedToPerformTheRequest
    case observationIsNil
}
