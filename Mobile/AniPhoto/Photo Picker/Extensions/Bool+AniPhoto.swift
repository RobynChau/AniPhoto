//
//  Bool+AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/11/3.
//

import Foundation

extension AniPhotoWrapper where Base == Bool {
    var intValue: Int {
        base ? 1 : 0
    }
}
