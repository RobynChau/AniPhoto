//
//  NSError+AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2022/8/3.
//

import Foundation

extension NSError {
    convenience init(message: String) {
        let userInfo = [NSLocalizedDescriptionKey: message]
        self.init(domain: "com.AniPhoto.error", code: -1, userInfo: userInfo)
    }
}

extension NSError {
    static let videoMergeError = NSError(message: "video merge failed")
    
    static let videoExportTypeError = NSError(message: "The mediaType of asset must be video")
    
    static let videoExportError = NSError(message: "Video export failed")
    
    static let assetSaveError = NSError(message: "Asset save failed")
    
    static let timeoutError = NSError(message: "timeout")
}
