//
//  SystemVolumeControl.swift
//  MyMediaPlayer
//
//  Created by wuweixin on 2019/8/22.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

import AVFoundation
import MediaPlayer

public protocol SystemVolumeControlDelegate: AnyObject {
    func systemVolumeDidChanged(_ outputVolume: Float)
}

extension SystemVolumeControlDelegate {
    func systemVolumeDidChanged(_ outputVolume: Float) {}
}


private class SystemVolumeView: MPVolumeView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInitilization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitilization()
    }
    
    func commonInitilization() {
        let transparent = UIImage()
        self.setVolumeThumbImage(transparent, for: .normal)
        self.setMaximumVolumeSliderImage(transparent, for: .normal)
        self.setMinimumVolumeSliderImage(transparent, for: .normal)
        self.setRouteButtonImage(transparent, for: .normal)
        self.volumeWarningSliderImage = transparent
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

public class SystemVolumeControl: NSObject {
    public weak var delegate: SystemVolumeControlDelegate?
    public var volume: Float {
        get {
            return AVAudioSession.sharedInstance().outputVolume
        }
        set {
            volumeSlider?.setValue(newValue, animated: true)
            volumeSlider?.sendActions(for: .touchUpInside)
        }
    }
    
    public override init() {
        super.init()
        
        self.volumeObserver = AVAudioSession.sharedInstance().observe(\.outputVolume, changeHandler: { [weak self] (session, _) in
            self?.delegate?.systemVolumeDidChanged(session.outputVolume)
        })
    }
    
    
    public func bind(into contrainerView: UIView) {
        let bounds = contrainerView.bounds
        systemVolumeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        systemVolumeView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 1)
        contrainerView.addSubview(systemVolumeView)
    }
    
    deinit {
        volumeObserver?.invalidate()
        volumeObserver = nil
    }
    
    private lazy var systemVolumeView: SystemVolumeView = SystemVolumeView()
    private lazy var volumeSlider: UISlider? = MPVolumeView.volumeSlider(in: systemVolumeView)
    private var volumeObserver: NSKeyValueObservation?
}


private extension MPVolumeView {
    class func volumeSlider(in rootView: UIView?) -> UISlider? {
        guard let view = rootView else {
            return nil
        }
        
        if let slider = view as? UISlider {
            return slider
        }
        
        for child in view.subviews {
            if let slider = volumeSlider(in: child) {
                return slider
            }
        }
        return nil
    }
}
