//
//  EPSCameraConfiguration.swift
//  AniPhoto
//
//  Created by PhatCH on 2021/11/10.
//

import UIKit
import AVFoundation

@objcMembers
public class EPSCameraConfiguration: NSObject {
    private var pri_allowTakePhoto = true
    /// Allow taking photos in the camera (Need allowSelectImage to be true). Defaults to true.
    public var allowTakePhoto: Bool {
        get {
            pri_allowTakePhoto && EPSPhotoConfiguration.default().allowSelectImage
        }
        set {
            pri_allowTakePhoto = newValue
        }
    }
    
    private var pri_allowRecordVideo = true
    /// Allow recording in the camera (Need allowSelectVideo to be true). Defaults to true.
    public var allowRecordVideo: Bool {
        get {
            pri_allowRecordVideo && EPSPhotoConfiguration.default().allowSelectVideo
        }
        set {
            pri_allowRecordVideo = newValue
        }
    }
    
    private var pri_minRecordDuration: EPSPhotoConfiguration.Second = 0
    /// Minimum recording duration. Defaults to 0.
    public var minRecordDuration: EPSPhotoConfiguration.Second {
        get {
            pri_minRecordDuration
        }
        set {
            pri_minRecordDuration = max(0, newValue)
        }
    }
    
    private var pri_maxRecordDuration: EPSPhotoConfiguration.Second = 20
    /// Maximum recording duration. Defaults to 20, minimum is 1.
    public var maxRecordDuration: EPSPhotoConfiguration.Second {
        get {
            pri_maxRecordDuration
        }
        set {
            pri_maxRecordDuration = max(1, newValue)
        }
    }
    
    /// Video resolution. Defaults to hd1920x1080.
    public var sessionPreset: EPSCameraConfiguration.CaptureSessionPreset = .hd1920x1080
    
    /// Camera focus mode. Defaults to continuousAutoFocus
    public var focusMode: EPSCameraConfiguration.FocusMode = .continuousAutoFocus
    
    /// Camera exposure mode. Defaults to continuousAutoExposure
    public var exposureMode: EPSCameraConfiguration.ExposureMode = .continuousAutoExposure
    
    /// Camera flash switch. Defaults to true.
    public var showFlashSwitch = true
    
    /// Whether to support switch camera. Defaults to true.
    public var allowSwitchCamera = true
    
    /// Video export format for recording video and editing video. Defaults to mov.
    public var videoExportType: EPSCameraConfiguration.VideoExportType = .mov
    
    /// The default camera position after entering the camera. Defaults to back.
    public var devicePosition: EPSCameraConfiguration.DevicePosition = .back
    
    private var pri_videoCodecType: Any?
    /// The codecs for video capture. Defaults to .h264
    @available(iOS 11.0, *)
    public var videoCodecType: AVVideoCodecType {
        get {
            (pri_videoCodecType as? AVVideoCodecType) ?? .h264
        }
        set {
            pri_videoCodecType = newValue
        }
    }
}

public extension EPSCameraConfiguration {
    @objc enum CaptureSessionPreset: Int {
        var avSessionPreset: AVCaptureSession.Preset {
            switch self {
            case .cif352x288:
                return .cif352x288
            case .vga640x480:
                return .vga640x480
            case .hd1280x720:
                return .hd1280x720
            case .hd1920x1080:
                return .hd1920x1080
            case .hd4K3840x2160:
                return .hd4K3840x2160
            case .photo:
                return .photo
            }
        }
        
        case cif352x288
        case vga640x480
        case hd1280x720
        case hd1920x1080
        case hd4K3840x2160
        case photo
    }
    
    @objc enum FocusMode: Int {
        var avFocusMode: AVCaptureDevice.FocusMode {
            switch self {
            case .autoFocus:
                return .autoFocus
            case .continuousAutoFocus:
                return .continuousAutoFocus
            }
        }
        
        case autoFocus
        case continuousAutoFocus
    }
    
    @objc enum ExposureMode: Int {
        var avFocusMode: AVCaptureDevice.ExposureMode {
            switch self {
            case .autoExpose:
                return .autoExpose
            case .continuousAutoExposure:
                return .continuousAutoExposure
            }
        }
        
        case autoExpose
        case continuousAutoExposure
    }
    
    @objc enum VideoExportType: Int {
        var format: String {
            switch self {
            case .mov:
                return "mov"
            case .mp4:
                return "mp4"
            }
        }
        
        var avFileType: AVFileType {
            switch self {
            case .mov:
                return .mov
            case .mp4:
                return .mp4
            }
        }
        
        case mov
        case mp4
    }
    
    @objc enum DevicePosition: Int {
        case back
        case front
        
        /// For custom camera
        var avDevicePosition: AVCaptureDevice.Position {
            switch self {
            case .back:
                return .back
            case .front:
                return .front
            }
        }
        
        /// For system camera
        var cameraDevice: UIImagePickerController.CameraDevice {
            switch self {
            case .back:
                return .rear
            case .front:
                return .front
            }
        }
    }
}

// MARK: chaining

public extension EPSCameraConfiguration {
    @discardableResult
    func allowTakePhoto(_ value: Bool) -> EPSCameraConfiguration {
        allowTakePhoto = value
        return self
    }
    
    @discardableResult
    func allowRecordVideo(_ value: Bool) -> EPSCameraConfiguration {
        allowRecordVideo = value
        return self
    }
    
    @discardableResult
    func minRecordDuration(_ duration: EPSPhotoConfiguration.Second) -> EPSCameraConfiguration {
        minRecordDuration = duration
        return self
    }
    
    @discardableResult
    func maxRecordDuration(_ duration: EPSPhotoConfiguration.Second) -> EPSCameraConfiguration {
        maxRecordDuration = duration
        return self
    }
    
    @discardableResult
    func sessionPreset(_ sessionPreset: EPSCameraConfiguration.CaptureSessionPreset) -> EPSCameraConfiguration {
        self.sessionPreset = sessionPreset
        return self
    }
    
    @discardableResult
    func focusMode(_ mode: EPSCameraConfiguration.FocusMode) -> EPSCameraConfiguration {
        focusMode = mode
        return self
    }
    
    @discardableResult
    func exposureMode(_ mode: EPSCameraConfiguration.ExposureMode) -> EPSCameraConfiguration {
        exposureMode = mode
        return self
    }
    
    @discardableResult
    func showFlashSwitch(_ value: Bool) -> EPSCameraConfiguration {
        showFlashSwitch = value
        return self
    }
    
    @discardableResult
    func allowSwitchCamera(_ value: Bool) -> EPSCameraConfiguration {
        allowSwitchCamera = value
        return self
    }
    
    @discardableResult
    func videoExportType(_ type: EPSCameraConfiguration.VideoExportType) -> EPSCameraConfiguration {
        videoExportType = type
        return self
    }
    
    @discardableResult
    func devicePosition(_ position: EPSCameraConfiguration.DevicePosition) -> EPSCameraConfiguration {
        devicePosition = position
        return self
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func videoCodecType(_ type: AVVideoCodecType) -> EPSCameraConfiguration {
        videoCodecType = type
        return self
    }
}
