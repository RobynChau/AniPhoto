//
//  AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/9/2.
//

import UIKit
import Foundation
import Photos

let version = "4.5.2"

public struct AniPhotoWrapper<Base> {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol AniPhotoCompatible: AnyObject { }

public protocol AniPhotoCompatibleValue { }

extension AniPhotoCompatible {
    public var eps: AniPhotoWrapper<Self> {
        get { AniPhotoWrapper(self) }
        set { }
    }
    
    public static var eps: AniPhotoWrapper<Self>.Type {
        get { AniPhotoWrapper<Self>.self }
        set { }
    }
}

extension AniPhotoCompatibleValue {
    public var eps: AniPhotoWrapper<Self> {
        get { AniPhotoWrapper(self) }
        set { }
    }
}

extension UIViewController: AniPhotoCompatible { }
extension UIColor: AniPhotoCompatible { }
extension UIImage: AniPhotoCompatible { }
extension CIImage: AniPhotoCompatible { }
extension PHAsset: AniPhotoCompatible { }
extension UIFont: AniPhotoCompatible { }
extension UIView: AniPhotoCompatible { }
extension UIGraphicsImageRenderer: AniPhotoCompatible { }

extension Array: AniPhotoCompatibleValue { }
extension String: AniPhotoCompatibleValue { }
extension CGFloat: AniPhotoCompatibleValue { }
extension Bool: AniPhotoCompatibleValue { }
