//
//  EPSResultModel.swift
//  AniPhoto
//
//  Created by PhatCH on 2022/9/7.
//

import UIKit
import Photos

public class EPSResultModel: NSObject {
    @objc public let asset: PHAsset
    
    @objc public let image: UIImage
    
    /// Whether the picture has been edited. Always false when `saveNewImageAfterEdit = true`.
    @objc public let isEdited: Bool
    
    /// Content of the last edit. Always nil when `saveNewImageAfterEdit = true`.
    @objc public let editModel: EPSEditImageModel?
    
    /// The order in which the user selects the models in the album. This index is not necessarily equal to the order of the model's index in the array, as some PHAssets requests may fail.
    @objc public let index: Int
    
    @objc public init(asset: PHAsset, image: UIImage, isEdited: Bool, editModel: EPSEditImageModel? = nil, index: Int) {
        self.asset = asset
        self.image = image
        self.isEdited = isEdited
        self.editModel = editModel
        self.index = index
        super.init()
    }
}

extension EPSResultModel {
    static func ==(lhs: EPSResultModel, rhs: EPSResultModel) -> Bool {
        return lhs.asset == rhs.asset
    }
}
