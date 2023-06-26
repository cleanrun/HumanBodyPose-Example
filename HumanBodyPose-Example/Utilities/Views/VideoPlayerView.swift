//
//  VideoPlayerView.swift
//  HumanBodyPose-Example
//
//  Created by cleanmac on 25/06/23.
//

import UIKit
import AVFoundation

protocol VideoPlayerViewDelegate: AnyObject {
    func didReceiveBuffer(_ sbuf: CMSampleBuffer)
    func didReceiveImage(_ cgImage: CGImage)
}

final class VideoPlayerView: UIView {
    weak var delegate: VideoPlayerViewDelegate?
    
    private var playerLayer: AVPlayerLayer!
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private(set) var player = AVPlayer()
    
    private var playerStatusObserver: NSKeyValueObservation?
    private var sampleBufferGenerator: AVSampleBufferGenerator?
    private var imageGenerator: AVAssetImageGenerator?
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = self.bounds
        CATransaction.commit()
    }
    
    private func commonInit() {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = frame
        playerLayer.videoGravity = .resizeAspect
        layer.addSublayer(playerLayer)
        
        addSubview(slider)
        NSLayoutConstraint.activate([
            slider.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            slider.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func setupPlayerItem(_ url: URL) {
        commonInit()
        
        //slider.isContinuous = false
        slider.addTarget(self, action: #selector(sliderAction(_:event:)), for: .valueChanged)
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        
        if let currentItem = player.currentItem, let timebase = currentItem.timebase {
            sampleBufferGenerator = AVSampleBufferGenerator(asset: currentItem.asset, timebase: nil)
        }
        
        playerStatusObserver = player.currentItem?.observe(\.status, changeHandler: { [unowned self] playerItem, change in
            guard playerItem.status == .readyToPlay else { return }
            
            if let duration = player.currentItem?.duration {
                let maximumSliderValue = Float(CMTimeGetSeconds(duration))
                slider.maximumValue = maximumSliderValue
            }
            
            player.addProgressObserver { [unowned self] duration in
                generateSampleBuffer(duration: duration)
                //generateImage()
            }
        })
    }
    
    private func generateSampleBuffer(duration: Double) {
        if let track = player.currentItem?.asset.tracks.first, let cursor = track.makeSampleCursor(presentationTimeStamp: CMTimeMakeWithSeconds(duration, preferredTimescale: 1)) {
            let request = AVSampleBufferRequest(start: cursor)
            do {
                if let sbuf = try self.sampleBufferGenerator?.makeSampleBuffer(for: request) {
                    delegate?.didReceiveBuffer(sbuf)
                }
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    private func generateImage() {
        guard let asset = player.currentItem?.asset else { return }
        
        if imageGenerator == nil {
            imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator?.appliesPreferredTrackTransform = true
        }
        
        imageGenerator?.generateCGImageAsynchronously(for: player.currentTime(), completionHandler: { [unowned self] image, time, error in
            guard error == nil else {
                print("Generate image failed with error: \(error!.localizedDescription)")
                return
            }
            
            if let image {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveImage(image)
                }
            }
        })
    }
    
    @objc private func sliderAction(_ sender: UISlider, event: UIEvent) {
        let value = slider.value
        let time = CMTimeMakeWithSeconds(Float64(value), preferredTimescale: 60000)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .ended:
                generateImage()
            default:
                break
            }
        }
    }
    
}
