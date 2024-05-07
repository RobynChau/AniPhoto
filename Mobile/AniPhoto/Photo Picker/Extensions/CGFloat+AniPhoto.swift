//
//  CGFloat+AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/11/10.
//

import UIKit

extension AniPhotoWrapper where Base == CGFloat {
    var toPi: CGFloat {
        return base / 180 * .pi
    }
}
