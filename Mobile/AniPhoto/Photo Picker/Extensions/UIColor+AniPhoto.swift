//
//  UIColor+AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/18.
//

import UIKit

extension AniPhotoWrapper where Base: UIColor {
    static var navBarColor: UIColor {
        EPSPhotoUIConfiguration.default().navBarColor
    }
    
    static var navBarColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().navBarColorOfPreviewVC
    }
    
    /// 相册列表界面导航标题颜色
    static var navTitleColor: UIColor {
        EPSPhotoUIConfiguration.default().navTitleColor
    }
    
    /// 预览大图界面导航标题颜色
    static var navTitleColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().navTitleColorOfPreviewVC
    }
    
    /// 框架样式为 embedAlbumList 时，title view 背景色
    static var navEmbedTitleViewBgColor: UIColor {
        EPSPhotoUIConfiguration.default().navEmbedTitleViewBgColor
    }
    
    /// 预览选择模式下 上方透明背景色
    static var previewBgColor: UIColor {
        EPSPhotoUIConfiguration.default().sheetTranslucentColor
    }
    
    /// 预览选择模式下 拍照/相册/取消 的背景颜色
    static var previewBtnBgColor: UIColor {
        EPSPhotoUIConfiguration.default().sheetBtnBgColor
    }
    
    /// 预览选择模式下 拍照/相册/取消 的字体颜色
    static var previewBtnTitleColor: UIColor {
        EPSPhotoUIConfiguration.default().sheetBtnTitleColor
    }
    
    /// 预览选择模式下 选择照片大于0时，取消按钮title颜色
    static var previewBtnHighlightTitleColor: UIColor {
        EPSPhotoUIConfiguration.default().sheetBtnTitleTintColor
    }
    
    /// 相册列表界面背景色
    static var albumListBgColor: UIColor {
        EPSPhotoUIConfiguration.default().albumListBgColor
    }
    
    /// 嵌入式相册列表下方透明区域颜色
    static var embedAlbumListTranslucentColor: UIColor {
        EPSPhotoUIConfiguration.default().embedAlbumListTranslucentColor
    }
    
    /// 相册列表界面 相册title颜色
    static var albumListTitleColor: UIColor {
        EPSPhotoUIConfiguration.default().albumListTitleColor
    }
    
    /// 相册列表界面 数量label颜色
    static var albumListCountColor: UIColor {
        EPSPhotoUIConfiguration.default().albumListCountColor
    }
    
    /// 分割线颜色
    static var separatorLineColor: UIColor {
        EPSPhotoUIConfiguration.default().separatorColor
    }
    
    /// 小图界面背景色
    static var thumbnailBgColor: UIColor {
        EPSPhotoUIConfiguration.default().thumbnailBgColor
    }
    
    /// 预览大图界面背景色
    static var previewVCBgColor: UIColor {
        EPSPhotoUIConfiguration.default().previewVCBgColor
    }
    
    /// 相册列表界面底部工具条底色
    static var bottomToolViewBgColor: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBgColor
    }
    
    /// 预览大图界面底部工具条底色
    static var bottomToolViewBgColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBgColorOfPreviewVC
    }
    
    /// 小图界面原图大小label字体颜色
    static var originalSizeLabelTextColor: UIColor {
        EPSPhotoUIConfiguration.default().originalSizeLabelTextColor
    }
    
    /// 预览大图界面原图大小label字体颜色
    static var originalSizeLabelTextColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().originalSizeLabelTextColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 可交互 状态标题颜色
    static var bottomToolViewBtnNormalTitleColor: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBtnNormalTitleColor
    }
    
    /// 相册列表界面底部工具栏 `完成` 按钮 可交互 状态标题颜色
    static var bottomToolViewDoneBtnNormalTitleColor: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewDoneBtnNormalTitleColor
    }
    
    /// 预览大图界面底部工具栏按钮 可交互 状态标题颜色
    static var bottomToolViewBtnNormalTitleColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBtnNormalTitleColorOfPreviewVC
    }
    
    /// 预览大图界面底部工具栏 `完成` 按钮 可交互 状态标题颜色
    static var bottomToolViewDoneBtnNormalTitleColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewDoneBtnNormalTitleColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 不可交互 状态标题颜色
    static var bottomToolViewBtnDisableTitleColor: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBtnDisableTitleColor
    }
    
    /// 相册列表界面底部工具栏 `完成` 按钮 不可交互 状态标题颜色
    static var bottomToolViewDoneBtnDisableTitleColor: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewDoneBtnDisableTitleColor
    }
    
    /// 预览大图界面底部工具栏按钮 不可交互 状态标题颜色
    static var bottomToolViewBtnDisableTitleColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBtnDisableTitleColorOfPreviewVC
    }
    
    /// 预览大图界面底部工具栏 `完成` 按钮 不可交互 状态标题颜色
    static var bottomToolViewDoneBtnDisableTitleColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewDoneBtnDisableTitleColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 可交互 状态背景颜色
    static var bottomToolViewBtnNormalBgColor: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBtnNormalBgColor
    }
    
    /// 预览大图界面底部工具栏按钮 可交互 状态背景颜色
    static var bottomToolViewBtnNormalBgColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBtnNormalBgColorOfPreviewVC
    }
    
    /// 相册列表界面底部工具栏按钮 不可交互 状态背景颜色
    static var bottomToolViewBtnDisableBgColor: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBtnDisableBgColor
    }
    
    /// 预览大图界面底部工具栏按钮 不可交互 状态背景颜色
    static var bottomToolViewBtnDisableBgColorOfPreviewVC: UIColor {
        EPSPhotoUIConfiguration.default().bottomToolViewBtnDisableBgColorOfPreviewVC
    }
    
    /// iOS14 limited 权限时候，小图界面下方显示 选择更多图片 标题颜色
    static var limitedAuthorityTipsColor: UIColor {
        return EPSPhotoUIConfiguration.default().limitedAuthorityTipsColor
    }
    
    /// 自定义相机录制视频时，进度条颜色
    static var cameraRecodeProgressColor: UIColor {
        EPSPhotoUIConfiguration.default().cameraRecodeProgressColor
    }
    
    /// 已选cell遮罩层颜色
    static var selectedMaskColor: UIColor {
        EPSPhotoUIConfiguration.default().selectedMaskColor
    }
    
    /// 已选cell border颜色
    static var selectedBorderColor: UIColor {
        EPSPhotoUIConfiguration.default().selectedBorderColor
    }
    
    /// 不能选择的cell上方遮罩层颜色
    static var invalidMaskColor: UIColor {
        EPSPhotoUIConfiguration.default().invalidMaskColor
    }
    
    /// 选中图片右上角index text color
    static var indexLabelTextColor: UIColor {
        EPSPhotoUIConfiguration.default().indexLabelTextColor
    }
    
    /// 选中图片右上角index background color
    static var indexLabelBgColor: UIColor {
        EPSPhotoUIConfiguration.default().indexLabelBgColor
    }
    
    /// 拍照cell 背景颜色
    static var cameraCellBgColor: UIColor {
        EPSPhotoUIConfiguration.default().cameraCellBgColor
    }
    
    /// 调整图片slider默认色
    static var adjustSliderNormalColor: UIColor {
        EPSPhotoUIConfiguration.default().adjustSliderNormalColor
    }
    
    /// 调整图片slider高亮色
    static var adjustSliderTintColor: UIColor {
        EPSPhotoUIConfiguration.default().adjustSliderTintColor
    }
    
    /// 图片编辑器中各种工具下方标题普通状态下的颜色
    static var imageEditorToolTitleNormalColor: UIColor {
        EPSPhotoUIConfiguration.default().imageEditorToolTitleNormalColor
    }
    
    /// 图片编辑器中各种工具下方标题高亮状态下的颜色
    static var imageEditorToolTitleTintColor: UIColor {
        EPSPhotoUIConfiguration.default().imageEditorToolTitleTintColor
    }
    
    /// 图片编辑器中各种工具图标高亮状态下的颜色
    static var imageEditorToolIconTintColor: UIColor? {
        EPSPhotoUIConfiguration.default().imageEditorToolIconTintColor
    }
    
    /// 编辑器中垃圾箱普通状态下的颜色
    static var trashCanBackgroundNormalColor: UIColor {
        EPSPhotoUIConfiguration.default().trashCanBackgroundNormalColor
    }
    
    /// 编辑器中垃圾箱高亮状态下的颜色
    static var trashCanBackgroundTintColor: UIColor {
        EPSPhotoUIConfiguration.default().trashCanBackgroundTintColor
    }
}

extension AniPhotoWrapper where Base: UIColor {
    /// - Parameters:
    ///   - r: 0~255
    ///   - g: 0~255
    ///   - b: 0~255
    ///   - a: 0~1
    static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> UIColor {
        return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
}
