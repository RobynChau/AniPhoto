//
//  Array+AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/10/9.
//

import Photos
import UIKit

extension AniPhotoWrapper where Base == [PHAsset] {
    func removeDuplicate() -> [PHAsset] {
        return base.enumerated().filter { index, value -> Bool in
            base.firstIndex(of: value) == index
        }.map { $0.element }
    }
}

extension AniPhotoWrapper where Base == [EPSResultModel] {
    func removeDuplicate() -> [EPSResultModel] {
        return base.enumerated().filter { index, value -> Bool in
            base.firstIndex(of: value) == index
        }.map { $0.element }
    }
}
