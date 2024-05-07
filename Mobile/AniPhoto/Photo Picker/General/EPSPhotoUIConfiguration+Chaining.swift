//
//  EPSPhotoUIConfiguration+Chaining.swift
//  AniPhoto
//
//  Created by PhatCH on 2022/4/19.
//

import UIKit

// MARK: chaining

public extension EPSPhotoUIConfiguration {
    @discardableResult
    func sortAscending(_ ascending: Bool) -> EPSPhotoUIConfiguration {
        sortAscending = ascending
        return self
    }
    
    @discardableResult
    func style(_ style: AniPhotoStyle) -> EPSPhotoUIConfiguration {
        self.style = style
        return self
    }
    
    @discardableResult
    func statusBarStyle(_ statusBarStyle: UIStatusBarStyle) -> EPSPhotoUIConfiguration {
        self.statusBarStyle = statusBarStyle
        return self
    }
    
    @discardableResult
    func navCancelButtonStyle(_ style: EPSPhotoUIConfiguration.CancelButtonStyle) -> EPSPhotoUIConfiguration {
        navCancelButtonStyle = style
        return self
    }
    
    @discardableResult
    func showStatusBarInPreviewInterface(_ value: Bool) -> EPSPhotoUIConfiguration {
        showStatusBarInPreviewInterface = value
        return self
    }
    
    @discardableResult
    func hudStyle(_ style: EPSProgressHUD.Style) -> EPSPhotoUIConfiguration {
        hudStyle = style
        return self
    }
    
    @discardableResult
    func adjustSliderType(_ type: ZLAdjustSliderType) -> EPSPhotoUIConfiguration {
        adjustSliderType = type
        return self
    }
    
    @discardableResult
    func cellCornerRadio(_ cornerRadio: CGFloat) -> EPSPhotoUIConfiguration {
        cellCornerRadio = cornerRadio
        return self
    }
    
    @discardableResult
    func customAlertClass(_ alertClass: EPSCustomAlertProtocol.Type?) -> EPSPhotoUIConfiguration {
        customAlertClass = alertClass
        return self
    }
    
    /// - Note: This property is ignored when using columnCountBlock.
    @discardableResult
    func columnCount(_ count: Int) -> EPSPhotoUIConfiguration {
        columnCount = count
        return self
    }
    
    @discardableResult
    func columnCountBlock(_ block: ((_ collectionViewWidth: CGFloat) -> Int)?) -> EPSPhotoUIConfiguration {
        columnCountBlock = block
        return self
    }
    
    @discardableResult
    func minimumInteritemSpacing(_ value: CGFloat) -> EPSPhotoUIConfiguration {
        minimumInteritemSpacing = value
        return self
    }
    
    @discardableResult
    func minimumLineSpacing(_ value: CGFloat) -> EPSPhotoUIConfiguration {
        minimumLineSpacing = value
        return self
    }
    
    @discardableResult
    func animateSelectBtnWhenSelectInThumbVC(_ animate: Bool) -> EPSPhotoUIConfiguration {
        animateSelectBtnWhenSelectInThumbVC = animate
        return self
    }
    
    @discardableResult
    func animateSelectBtnWhenSelectInPreviewVC(_ animate: Bool) -> EPSPhotoUIConfiguration {
        animateSelectBtnWhenSelectInPreviewVC = animate
        return self
    }
    
    @discardableResult
    func selectBtnAnimationDuration(_ duration: CFTimeInterval) -> EPSPhotoUIConfiguration {
        selectBtnAnimationDuration = duration
        return self
    }
    
    @discardableResult
    func showIndexOnSelectBtn(_ value: Bool) -> EPSPhotoUIConfiguration {
        showIndexOnSelectBtn = value
        return self
    }
    
    @discardableResult
    func showScrollToBottomBtn(_ value: Bool) -> EPSPhotoUIConfiguration {
        showScrollToBottomBtn = value
        return self
    }
    
    @discardableResult
    func showCaptureImageOnTakePhotoBtn(_ value: Bool) -> EPSPhotoUIConfiguration {
        showCaptureImageOnTakePhotoBtn = value
        return self
    }
    
    @discardableResult
    func showSelectedMask(_ value: Bool) -> EPSPhotoUIConfiguration {
        showSelectedMask = value
        return self
    }
    
    @discardableResult
    func showSelectedBorder(_ value: Bool) -> EPSPhotoUIConfiguration {
        showSelectedBorder = value
        return self
    }
    
    @discardableResult
    func showInvalidMask(_ value: Bool) -> EPSPhotoUIConfiguration {
        showInvalidMask = value
        return self
    }
    
    @discardableResult
    func showSelectedPhotoPreview(_ value: Bool) -> EPSPhotoUIConfiguration {
        showSelectedPhotoPreview = value
        return self
    }
    
    @discardableResult
    func showAddPhotoButton(_ value: Bool) -> EPSPhotoUIConfiguration {
        showAddPhotoButton = value
        return self
    }
    
    @discardableResult
    func showEnterSettingTips(_ value: Bool) -> EPSPhotoUIConfiguration {
        showEnterSettingTips = value
        return self
    }
    
    @discardableResult
    func timeout(_ timeout: TimeInterval) -> EPSPhotoUIConfiguration {
        self.timeout = timeout
        return self
    }
    
    @discardableResult
    func navViewBlurEffectOfAlbumList(_ effect: UIBlurEffect?) -> EPSPhotoUIConfiguration {
        navViewBlurEffectOfAlbumList = effect
        return self
    }
    
    @discardableResult
    func navViewBlurEffectOfPreview(_ effect: UIBlurEffect?) -> EPSPhotoUIConfiguration {
        navViewBlurEffectOfPreview = effect
        return self
    }
    
    @discardableResult
    func bottomViewBlurEffectOfAlbumList(_ effect: UIBlurEffect?) -> EPSPhotoUIConfiguration {
        bottomViewBlurEffectOfAlbumList = effect
        return self
    }
    
    @discardableResult
    func bottomViewBlurEffectOfPreview(_ effect: UIBlurEffect?) -> EPSPhotoUIConfiguration {
        bottomViewBlurEffectOfPreview = effect
        return self
    }
    
    @discardableResult
    func customImageNames(_ names: [String]) -> EPSPhotoUIConfiguration {
        customImageNames = names
        return self
    }
    
    @discardableResult
    func customImageForKey(_ map: [String: UIImage?]) -> EPSPhotoUIConfiguration {
        customImageForKey = map
        return self
    }
    
    @discardableResult
    func languageType(_ type: EPSLanguageType) -> EPSPhotoUIConfiguration {
        languageType = type
        return self
    }
    
    @discardableResult
    func customLanguageKeyValue(_ map: [ZLLocalLanguageKey: String]) -> EPSPhotoUIConfiguration {
        customLanguageKeyValue = map
        return self
    }
    
    @discardableResult
    func themeFontName(_ name: String) -> EPSPhotoUIConfiguration {
        themeFontName = name
        return self
    }
    
    @discardableResult
    func themeColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        themeColor = color
        return self
    }
    
    @discardableResult
    func sheetTranslucentColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        sheetTranslucentColor = color
        return self
    }
    
    @discardableResult
    func sheetBtnBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        sheetBtnBgColor = color
        return self
    }
    
    @discardableResult
    func sheetBtnTitleColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        sheetBtnTitleColor = color
        return self
    }
    
    @discardableResult
    func sheetBtnTitleTintColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        sheetBtnTitleTintColor = color
        return self
    }
    
    @discardableResult
    func navBarColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        navBarColor = color
        return self
    }
    
    @discardableResult
    func navBarColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        navBarColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func navTitleColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        navTitleColor = color
        return self
    }
    
    @discardableResult
    func navTitleColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        navTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func navEmbedTitleViewBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        navEmbedTitleViewBgColor = color
        return self
    }
    
    @discardableResult
    func albumListBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        albumListBgColor = color
        return self
    }
    
    @discardableResult
    func embedAlbumListTranslucentColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        embedAlbumListTranslucentColor = color
        return self
    }
    
    @discardableResult
    func albumListTitleColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        albumListTitleColor = color
        return self
    }
    
    @discardableResult
    func albumListCountColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        albumListCountColor = color
        return self
    }
    
    @discardableResult
    func separatorColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        separatorColor = color
        return self
    }
    
    @discardableResult
    func thumbnailBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        thumbnailBgColor = color
        return self
    }
    
    @discardableResult
    func previewVCBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        previewVCBgColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBgColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBgColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func originalSizeLabelTextColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        originalSizeLabelTextColor = color
        return self
    }
    
    @discardableResult
    func originalSizeLabelTextColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        originalSizeLabelTextColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnNormalTitleColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBtnNormalTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewDoneBtnNormalTitleColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewDoneBtnNormalTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnNormalTitleColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBtnNormalTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewDoneBtnNormalTitleColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewDoneBtnNormalTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnDisableTitleColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBtnDisableTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewDoneBtnDisableTitleColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewDoneBtnDisableTitleColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnDisableTitleColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBtnDisableTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewDoneBtnDisableTitleColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewDoneBtnDisableTitleColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnNormalBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBtnNormalBgColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnNormalBgColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBtnNormalBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnDisableBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBtnDisableBgColor = color
        return self
    }
    
    @discardableResult
    func bottomToolViewBtnDisableBgColorOfPreviewVC(_ color: UIColor) -> EPSPhotoUIConfiguration {
        bottomToolViewBtnDisableBgColorOfPreviewVC = color
        return self
    }
    
    @discardableResult
    func limitedAuthorityTipsColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        limitedAuthorityTipsColor = color
        return self
    }
    
    @discardableResult
    func cameraRecodeProgressColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        cameraRecodeProgressColor = color
        return self
    }
    
    @discardableResult
    func selectedMaskColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        selectedMaskColor = color
        return self
    }
    
    @discardableResult
    func selectedBorderColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        selectedBorderColor = color
        return self
    }
    
    @discardableResult
    func invalidMaskColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        invalidMaskColor = color
        return self
    }
    
    @discardableResult
    func indexLabelTextColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        indexLabelTextColor = color
        return self
    }
    
    @discardableResult
    func indexLabelBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        indexLabelBgColor = color
        return self
    }
    
    @discardableResult
    func cameraCellBgColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        cameraCellBgColor = color
        return self
    }
    
    @discardableResult
    func adjustSliderNormalColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        adjustSliderNormalColor = color
        return self
    }
    
    @discardableResult
    func adjustSliderTintColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        adjustSliderTintColor = color
        return self
    }
    
    @discardableResult
    func imageEditorToolTitleNormalColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        imageEditorToolTitleNormalColor = color
        return self
    }
    
    @discardableResult
    func imageEditorToolTitleTintColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        imageEditorToolTitleTintColor = color
        return self
    }
    
    @discardableResult
    func imageEditorToolIconTintColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        imageEditorToolIconTintColor = color
        return self
    }
    
    @discardableResult
    func trashCanBackgroundNormalColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        trashCanBackgroundNormalColor = color
        return self
    }
    
    @discardableResult
    func trashCanBackgroundTintColor(_ color: UIColor) -> EPSPhotoUIConfiguration {
        trashCanBackgroundTintColor = color
        return self
    }
}
