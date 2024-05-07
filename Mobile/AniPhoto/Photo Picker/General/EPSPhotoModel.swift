//
//  ZLPhotoModel.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/11.
//

import UIKit
import Photos

public extension EPSPhotoModel {
    enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
}

@objcMembers
public class EPSPhotoModel: NSObject {
    public let ident: String
    
    public let asset: PHAsset

    public var type: EPSPhotoModel.MediaType = .unknown
    
    public var duration = ""
    
    public var isSelected = false
    
    private var pri_dataSize: EPSPhotoConfiguration.KBUnit?
    
    public var dataSize: EPSPhotoConfiguration.KBUnit? {
        if let pri_dataSize = pri_dataSize {
            return pri_dataSize
        }
        
        let size = EPSPhotoManager.fetchAssetSize(for: asset)
        pri_dataSize = size
        
        return size
    }
    
    private var pri_editImage: UIImage?
    
    public var editImage: UIImage? {
        set {
            pri_editImage = newValue
        }
        get {
            if let _ = editImageModel {
                return pri_editImage
            } else {
                return nil
            }
        }
    }
    
    public var second: EPSPhotoConfiguration.Second {
        guard type == .video else {
            return 0
        }
        return Int(round(asset.duration))
    }
    
    public var whRatio: CGFloat {
        return CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }
    
    public var previewSize: CGSize {
        let scale: CGFloat = UIScreen.main.scale
        if whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, EPSMaxImageWidth) * scale
            let w = h * whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, EPSMaxImageWidth) * scale
            let h = w / whRatio
            return CGSize(width: w, height: h)
        }
    }
    
    // Content of the last edit.
    public var editImageModel: EPSEditImageModel?
    
    public init(asset: PHAsset) {
        ident = asset.localIdentifier
        self.asset = asset
        super.init()
        
        type = transformAssetType(for: asset)
        if type == .video {
            duration = transformDuration(for: asset)
        }
    }
    
    public func transformAssetType(for asset: PHAsset) -> EPSPhotoModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if asset.eps.isGif {
                return .gif
            }
            if asset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            return .image
        default:
            return .unknown
        }
    }
    
    public func transformDuration(for asset: PHAsset) -> String {
        let dur = Int(round(asset.duration))
        
        switch dur {
        case 0..<60:
            return String(format: "00:%02d", dur)
        case 60..<3600:
            let m = dur / 60
            let s = dur % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = dur / 3600
            let m = (dur % 3600) / 60
            let s = dur % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
}

public extension EPSPhotoModel {
    static func == (lhs: EPSPhotoModel, rhs: EPSPhotoModel) -> Bool {
        return lhs.ident == rhs.ident
    }
}
