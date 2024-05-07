//
//  EPSPhotoConfiguration+Chaining.swift
//  AniPhoto
//
//  Created by PhatCH on 2021/11/1.
//

import UIKit
import Photos

public extension EPSPhotoConfiguration {
    @discardableResult
    func maxSelectCount(_ count: Int) -> EPSPhotoConfiguration {
        maxSelectCount = count
        return self
    }
    
    @discardableResult
    func maxVideoSelectCount(_ count: Int) -> EPSPhotoConfiguration {
        maxVideoSelectCount = count
        return self
    }
    
    @discardableResult
    func minVideoSelectCount(_ count: Int) -> EPSPhotoConfiguration {
        minVideoSelectCount = count
        return self
    }
    
    @discardableResult
    func allowMixSelect(_ value: Bool) -> EPSPhotoConfiguration {
        allowMixSelect = value
        return self
    }
    
    @discardableResult
    func maxPreviewCount(_ count: Int) -> EPSPhotoConfiguration {
        maxPreviewCount = count
        return self
    }
    
    @discardableResult
    func initialIndex(_ index: Int) -> EPSPhotoConfiguration {
        initialIndex = index
        return self
    }
    
    @discardableResult
    func allowSelectImage(_ value: Bool) -> EPSPhotoConfiguration {
        allowSelectImage = value
        return self
    }
    
    @discardableResult
    @objc func allowSelectVideo(_ value: Bool) -> EPSPhotoConfiguration {
        allowSelectVideo = value
        return self
    }
    
    @discardableResult
    @objc func downloadVideoBeforeSelecting(_ value: Bool) -> EPSPhotoConfiguration {
        downloadVideoBeforeSelecting = value
        return self
    }
    
    @discardableResult
    func allowSelectGif(_ value: Bool) -> EPSPhotoConfiguration {
        allowSelectGif = value
        return self
    }
    
    @discardableResult
    func allowSelectLivePhoto(_ value: Bool) -> EPSPhotoConfiguration {
        allowSelectLivePhoto = value
        return self
    }
    
    @discardableResult
    func allowTakePhotoInLibrary(_ value: Bool) -> EPSPhotoConfiguration {
        allowTakePhotoInLibrary = value
        return self
    }
    
    @discardableResult
    func callbackDirectlyAfterTakingPhoto(_ value: Bool) -> EPSPhotoConfiguration {
        callbackDirectlyAfterTakingPhoto = value
        return self
    }
    
    @discardableResult
    func allowEditImage(_ value: Bool) -> EPSPhotoConfiguration {
        allowEditImage = value
        return self
    }
    
    @discardableResult
    func allowEditVideo(_ value: Bool) -> EPSPhotoConfiguration {
        allowEditVideo = value
        return self
    }
    
    @discardableResult
    func editAfterSelectThumbnailImage(_ value: Bool) -> EPSPhotoConfiguration {
        editAfterSelectThumbnailImage = value
        return self
    }
    
    @discardableResult
    func cropVideoAfterSelectThumbnail(_ value: Bool) -> EPSPhotoConfiguration {
        cropVideoAfterSelectThumbnail = value
        return self
    }
    
    @discardableResult
    func saveNewImageAfterEdit(_ value: Bool) -> EPSPhotoConfiguration {
        saveNewImageAfterEdit = value
        return self
    }
    
    @discardableResult
    func allowSlideSelect(_ value: Bool) -> EPSPhotoConfiguration {
        allowSlideSelect = value
        return self
    }
    
    @discardableResult
    func autoScrollWhenSlideSelectIsActive(_ value: Bool) -> EPSPhotoConfiguration {
        autoScrollWhenSlideSelectIsActive = value
        return self
    }
    
    @discardableResult
    func autoScrollMaxSpeed(_ speed: CGFloat) -> EPSPhotoConfiguration {
        autoScrollMaxSpeed = speed
        return self
    }
    
    @discardableResult
    func allowDragSelect(_ value: Bool) -> EPSPhotoConfiguration {
        allowDragSelect = value
        return self
    }
    
    @discardableResult
    func allowSelectOriginal(_ value: Bool) -> EPSPhotoConfiguration {
        allowSelectOriginal = value
        return self
    }
    
    @discardableResult
    func alwaysRequestOriginal(_ value: Bool) -> EPSPhotoConfiguration {
        alwaysRequestOriginal = value
        return self
    }
    
    @discardableResult
    func allowPreviewPhotos(_ value: Bool) -> EPSPhotoConfiguration {
        allowPreviewPhotos = value
        return self
    }
    
    @discardableResult
    func showPreviewButtonInAlbum(_ value: Bool) -> EPSPhotoConfiguration {
        showPreviewButtonInAlbum = value
        return self
    }
    
    @discardableResult
    func showSelectCountOnDoneBtn(_ value: Bool) -> EPSPhotoConfiguration {
        showSelectCountOnDoneBtn = value
        return self
    }
    
    @discardableResult
    func showSelectBtnWhenSingleSelect(_ value: Bool) -> EPSPhotoConfiguration {
        showSelectBtnWhenSingleSelect = value
        return self
    }
    
    @discardableResult
    func showSelectedIndex(_ value: Bool) -> EPSPhotoConfiguration {
        showSelectedIndex = value
        return self
    }
    
    @discardableResult
    func maxEditVideoTime(_ second: Second) -> EPSPhotoConfiguration {
        maxEditVideoTime = second
        return self
    }
    
    @discardableResult
    func maxSelectVideoDuration(_ duration: Second) -> EPSPhotoConfiguration {
        maxSelectVideoDuration = duration
        return self
    }
    
    @discardableResult
    func minSelectVideoDuration(_ duration: Second) -> EPSPhotoConfiguration {
        minSelectVideoDuration = duration
        return self
    }
    
    @discardableResult
    func maxSelectVideoDataSize(_ size: EPSPhotoConfiguration.KBUnit) -> EPSPhotoConfiguration {
        maxSelectVideoDataSize = size
        return self
    }
    
    @discardableResult
    func minSelectVideoDataSize(_ size: EPSPhotoConfiguration.KBUnit) -> EPSPhotoConfiguration {
        minSelectVideoDataSize = size
        return self
    }
    
    @discardableResult
    func editImageConfiguration(_ configuration: EPSImageEditorConfiguration) -> EPSPhotoConfiguration {
        editImageConfiguration = configuration
        return self
    }
    
    @discardableResult
    func useCustomCamera(_ value: Bool) -> EPSPhotoConfiguration {
        useCustomCamera = value
        return self
    }
    
    @discardableResult
    func cameraConfiguration(_ configuration: EPSCameraConfiguration) -> EPSPhotoConfiguration {
        cameraConfiguration = configuration
        return self
    }
    
    @discardableResult
    func canSelectAsset(_ block: ((PHAsset) -> Bool)?) -> EPSPhotoConfiguration {
        canSelectAsset = block
        return self
    }
    
    @discardableResult
    func didSelectAsset(_ block: ((PHAsset) -> Void)?) -> EPSPhotoConfiguration {
        didSelectAsset = block
        return self
    }
    
    @discardableResult
    func didDeselectAsset(_ block: ((PHAsset) -> Void)?) -> EPSPhotoConfiguration {
        didDeselectAsset = block
        return self
    }
    
    @discardableResult
    func maxFrameCountForGIF(_ frameCount: Int) -> EPSPhotoConfiguration {
        maxFrameCountForGIF = frameCount
        return self
    }
    
    @discardableResult
    func gifPlayBlock(_ block: ((UIImageView, Data, [AnyHashable: Any]?) -> Void)?) -> EPSPhotoConfiguration {
        gifPlayBlock = block
        return self
    }
    
    @discardableResult
    func pauseGIFBlock(_ block: ((UIImageView) -> Void)?) -> EPSPhotoConfiguration {
        pauseGIFBlock = block
        return self
    }
    
    @discardableResult
    func resumeGIFBlock(_ block: ((UIImageView) -> Void)?) -> EPSPhotoConfiguration {
        resumeGIFBlock = block
        return self
    }
    
    @discardableResult
    func noAuthorityCallback(_ callback: ((ZLNoAuthorityType) -> Void)?) -> EPSPhotoConfiguration {
        noAuthorityCallback = callback
        return self
    }
    
    @discardableResult
    func customAlertWhenNoAuthority(_ callback: ((ZLNoAuthorityType) -> Void)?) -> EPSPhotoConfiguration {
        customAlertWhenNoAuthority = callback
        return self
    }
    
    @discardableResult
    func operateBeforeDoneAction(_ block: ((UIViewController, @escaping () -> Void) -> Void)?) -> EPSPhotoConfiguration {
        operateBeforeDoneAction = block
        return self
    }
}
