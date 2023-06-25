//
//  AVPlayer+Extension.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 25/06/23.
//

import AVFoundation

extension AVPlayer {

    /// Source: https://stackoverflow.com/a/48281081/8279130
    @discardableResult func addProgressObserver(timescale: CMTimeScale = 10, completion: @escaping ((Double) -> Void)) -> Any {
        addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: timescale), queue: .main, using: { time in
            let currentDuration = CMTimeGetSeconds(time)
            completion(Double(currentDuration))
        })
    }
}
