//
//  EPSAlbumListModel.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/11.
//

import UIKit
import Photos

@objcMembers
public class EPSAlbumListModel: NSObject {
    public let title: String
    
    public var count: Int {
        return result.count
    }
    
    public var result: PHFetchResult<PHAsset>
    
    public let collection: PHAssetCollection
    
    public let option: PHFetchOptions
    
    public let isCameraRoll: Bool
    
    public var headImageAsset: PHAsset? {
        return result.lastObject
    }
    
    public var models: [EPSPhotoModel] = []
    
    // 暂未用到
    private var selectedModels: [EPSPhotoModel] = []
    
    // 暂未用到
    private var selectedCount = 0
    
    public init(
        title: String,
        result: PHFetchResult<PHAsset>,
        collection: PHAssetCollection,
        option: PHFetchOptions,
        isCameraRoll: Bool
    ) {
        self.title = title
        self.result = result
        self.collection = collection
        self.option = option
        self.isCameraRoll = isCameraRoll
    }
    
    public func refetchPhotos() {
        let models = EPSPhotoManager.fetchPhoto(
            in: result,
            ascending: EPSPhotoUIConfiguration.default().sortAscending,
            allowSelectImage: EPSPhotoConfiguration.default().allowSelectImage,
            allowSelectVideo: EPSPhotoConfiguration.default().allowSelectVideo
        )
        self.models.removeAll()
        self.models.append(contentsOf: models)
    }
    
    func refreshResult() {
        result = PHAsset.fetchAssets(in: collection, options: option)
    }
}

extension EPSAlbumListModel {
    static func ==(lhs: EPSAlbumListModel, rhs: EPSAlbumListModel) -> Bool {
        return lhs.title == rhs.title &&
            lhs.count == rhs.count &&
            lhs.headImageAsset?.localIdentifier == rhs.headImageAsset?.localIdentifier
    }
}
