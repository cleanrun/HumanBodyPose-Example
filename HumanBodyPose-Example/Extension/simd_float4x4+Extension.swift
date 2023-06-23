//
//  simd_float4x4+Extension.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 23/06/23.
//

import simd
import SceneKit

extension simd_float4x4 {
    var positionVector3: SCNVector3 {
        SCNVector3Make(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }
}
