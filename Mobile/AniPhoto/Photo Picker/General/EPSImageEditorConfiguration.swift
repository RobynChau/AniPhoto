//
//  ZLEditImageConfiguration.swift
//  AniPhoto
//
//  Created by PhatCH on 2021/12/17.
//

import UIKit

/// Provide an image sticker container view that conform to this protocol must be a subclass of UIView
/// 必须是UIView的子类遵循这个协议
@objc public protocol ZLImageStickerContainerDelegate {
    @objc var selectImageBlock: ((UIImage) -> Void)? { get set }
    
    @objc var hideBlock: (() -> Void)? { get set }
    
    @objc func show(in view: UIView)
}

@objcMembers
public class EPSImageEditorConfiguration: NSObject {
    private static let defaultColors: [UIColor] = [
        .white,
        .black,
        .eps.rgba(249, 80, 81),
        .eps.rgba(248, 156, 59),
        .eps.rgba(255, 195, 0),
        .eps.rgba(145, 211, 0),
        .eps.rgba(0, 193, 94),
        .eps.rgba(16, 173, 254),
        .eps.rgba(16, 132, 236),
        .eps.rgba(99, 103, 240),
        .eps.rgba(127, 127, 127)
    ]
    
    private var pri_tools: [EPSImageEditorConfiguration.EditTool] = EPSImageEditorConfiguration.EditTool.allCases
    /// Edit image tools. (Default order is draw, clip, imageSticker, textSticker, mosaic, filtter)
    /// Because Objective-C Array can't contain Enum styles, so this property is invalid in Objective-C.
    /// - warning: If you want to use the image sticker feature, you must provide a view that implements ZLImageStickerContainerDelegate.
    public var tools: [EPSImageEditorConfiguration.EditTool] {
        get {
            if pri_tools.isEmpty {
                return EPSImageEditorConfiguration.EditTool.allCases
            } else {
                return pri_tools
            }
        }
        set {
            pri_tools = newValue
        }
    }
    
    /// Edit image tools.  (This property is only for objc).
    /// - warning: If you want to use the image sticker feature, you must provide a view that implements ZLImageStickerContainerDelegate.
    public var tools_objc: [Int] = [] {
        didSet {
            tools = tools_objc.compactMap { EPSImageEditorConfiguration.EditTool(rawValue: $0) }
        }
    }
    
    private var pri_drawColors = EPSImageEditorConfiguration.defaultColors
    /// Draw colors for image editor.
    public var drawColors: [UIColor] {
        get {
            if pri_drawColors.isEmpty {
                return EPSImageEditorConfiguration.defaultColors
            } else {
                return pri_drawColors
            }
        }
        set {
            pri_drawColors = newValue
        }
    }
    
    /// The default draw color. If this color not in editImageDrawColors, will pick the first color in editImageDrawColors as the default.
    public var defaultDrawColor: UIColor = .eps.rgba(249, 80, 81)
    
    private var pri_clipRatios: [ZLImageClipRatio] = [.custom]
    /// Edit ratios for image editor.
    public var clipRatios: [ZLImageClipRatio] {
        get {
            if pri_clipRatios.isEmpty {
                return [.custom]
            } else {
                return pri_clipRatios
            }
        }
        set {
            pri_clipRatios = newValue
        }
    }
    
    private var pri_textStickerTextColors: [UIColor] = EPSImageEditorConfiguration.defaultColors
    /// Text sticker colors for image editor.
    public var textStickerTextColors: [UIColor] {
        get {
            if pri_textStickerTextColors.isEmpty {
                return EPSImageEditorConfiguration.defaultColors
            } else {
                return pri_textStickerTextColors
            }
        }
        set {
            pri_textStickerTextColors = newValue
        }
    }
    
    /// The default text sticker color. If this color not in textStickerTextColors, will pick the first color in textStickerTextColors as the default.
    public var textStickerDefaultTextColor = UIColor.white
    
    /// The default font of text sticker.
    public var textStickerDefaultFont: UIFont?
    
    private var pri_filters: [EPSFilter] = EPSFilter.all
    /// Filters for image editor.
    public var filters: [EPSFilter] {
        get {
            if pri_filters.isEmpty {
                return EPSFilter.all
            } else {
                return pri_filters
            }
        }
        set {
            pri_filters = newValue
        }
    }
    
    public var imageStickerContainerView: (UIView & ZLImageStickerContainerDelegate)?
    
    private var pri_adjustTools: [EPSImageEditorConfiguration.AdjustTool] = EPSImageEditorConfiguration.AdjustTool.allCases
    /// Adjust image tools. (Default order is brightness, contrast, saturation)
    /// Valid when the tools contain EditTool.adjust
    /// Because Objective-C Array can't contain Enum styles, so this property is invalid in Objective-C.
    public var adjustTools: [EPSImageEditorConfiguration.AdjustTool] {
        get {
            if pri_adjustTools.isEmpty {
                return EPSImageEditorConfiguration.AdjustTool.allCases
            } else {
                return pri_adjustTools
            }
        }
        set {
            pri_adjustTools = newValue
        }
    }
    
    /// Adjust image tools.  (This property is only for objc).
    /// Valid when the tools contain EditTool.adjust
    public var adjustTools_objc: [Int] = [] {
        didSet {
            adjustTools = adjustTools_objc.compactMap { EPSImageEditorConfiguration.AdjustTool(rawValue: $0) }
        }
    }
    
    /// If image edit tools only has clip and this property is true. When you click edit, the cropping interface (i.e. ZLClipImageViewController) will be displayed. Defaults to false.
    public var showClipDirectlyIfOnlyHasClipTool = false
    
    /// Give an impact feedback when the adjust slider value is zero. Defaults to true.
    public var impactFeedbackWhenAdjustSliderValueIsZero = true
    
    /// Impact feedback style. Defaults to .medium
    public var impactFeedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    
    /// Whether to keep clipped area dimmed during adjustments. Defaults to false
    public var dimClippedAreaDuringAdjustments = false

    /// Minimum zoom scale, allowing the user to make the edited photo smaller, so it does not overlap top and bottom tools menu. Defaults to 1.0
    public var minimumZoomScale = 1.0
}

public extension EPSImageEditorConfiguration {
    @objc enum EditTool: Int, CaseIterable {
        case draw
        case clip
        case imageSticker
        case textSticker
        case mosaic
        case filter
        case adjust
    }
    
    @objc enum AdjustTool: Int, CaseIterable {
        case brightness
        case contrast
        case saturation
        
        var key: String {
            switch self {
            case .brightness:
                return kCIInputBrightnessKey
            case .contrast:
                return kCIInputContrastKey
            case .saturation:
                return kCIInputSaturationKey
            }
        }
        
        func filterValue(_ value: Float) -> Float {
            switch self {
            case .brightness:
                // 亮度范围-1---1，默认0，这里除以3，取 -0.33---0.33
                return value / 3
            case .contrast:
                // 对比度范围0---4，默认1，这里计算下取0.5---2.5
                let v: Float
                if value < 0 {
                    v = 1 + value * (1 / 2)
                } else {
                    v = 1 + value * (3 / 2)
                }
                return v
            case .saturation:
                // 饱和度范围0---2，默认1
                return value + 1
            }
        }
    }
}

// MARK: chaining

public extension EPSImageEditorConfiguration {
    @discardableResult
    func tools(_ tools: [EPSImageEditorConfiguration.EditTool]) -> EPSImageEditorConfiguration {
        self.tools = tools
        return self
    }
    
    @discardableResult
    func drawColors(_ colors: [UIColor]) -> EPSImageEditorConfiguration {
        drawColors = colors
        return self
    }
    
    func defaultDrawColor(_ color: UIColor) -> EPSImageEditorConfiguration {
        defaultDrawColor = color
        return self
    }
    
    @discardableResult
    func clipRatios(_ ratios: [ZLImageClipRatio]) -> EPSImageEditorConfiguration {
        clipRatios = ratios
        return self
    }
    
    @discardableResult
    func textStickerTextColors(_ colors: [UIColor]) -> EPSImageEditorConfiguration {
        textStickerTextColors = colors
        return self
    }
    
    @discardableResult
    func textStickerDefaultTextColor(_ color: UIColor) -> EPSImageEditorConfiguration {
        textStickerDefaultTextColor = color
        return self
    }
    
    @discardableResult
    func textStickerDefaultFont(_ font: UIFont?) -> EPSImageEditorConfiguration {
        textStickerDefaultFont = font
        return self
    }
    
    @discardableResult
    func filters(_ filters: [EPSFilter]) -> EPSImageEditorConfiguration {
        self.filters = filters
        return self
    }
    
    @discardableResult
    func imageStickerContainerView(_ view: (UIView & ZLImageStickerContainerDelegate)?) -> EPSImageEditorConfiguration {
        imageStickerContainerView = view
        return self
    }
    
    @discardableResult
    func adjustTools(_ tools: [EPSImageEditorConfiguration.AdjustTool]) -> EPSImageEditorConfiguration {
        adjustTools = tools
        return self
    }
    
    @discardableResult
    func showClipDirectlyIfOnlyHasClipTool(_ value: Bool) -> EPSImageEditorConfiguration {
        showClipDirectlyIfOnlyHasClipTool = value
        return self
    }
    
    @discardableResult
    func impactFeedbackWhenAdjustSliderValueIsZero(_ value: Bool) -> EPSImageEditorConfiguration {
        impactFeedbackWhenAdjustSliderValueIsZero = value
        return self
    }
    
    @discardableResult
    func impactFeedbackStyle(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> EPSImageEditorConfiguration {
        impactFeedbackStyle = style
        return self
    }
    
    @discardableResult
    func dimClippedAreaDuringAdjustments(_ value: Bool) -> EPSImageEditorConfiguration {
        dimClippedAreaDuringAdjustments = value
        return self
    }
    
    @discardableResult
    func minimumZoomScale(_ value: CGFloat) -> EPSImageEditorConfiguration {
        minimumZoomScale = value
        return self
    }
}

// MARK: 裁剪比例

public class ZLImageClipRatio: NSObject {
    @objc public var title: String
    
    @objc public let whRatio: CGFloat
    
    @objc public let isCircle: Bool
    
    @objc public init(title: String, whRatio: CGFloat, isCircle: Bool = false) {
        self.title = title
        self.whRatio = isCircle ? 1 : whRatio
        self.isCircle = isCircle
        super.init()
    }
}

extension ZLImageClipRatio {
    static func == (lhs: ZLImageClipRatio, rhs: ZLImageClipRatio) -> Bool {
        return lhs.whRatio == rhs.whRatio && lhs.title == rhs.title
    }
}

public extension ZLImageClipRatio {
    @objc static let custom = ZLImageClipRatio(title: "custom", whRatio: 0)
    
    @objc static let circle = ZLImageClipRatio(title: "circle", whRatio: 1, isCircle: true)
    
    @objc static let wh1x1 = ZLImageClipRatio(title: "1 : 1", whRatio: 1)
    
    @objc static let wh3x4 = ZLImageClipRatio(title: "3 : 4", whRatio: 3.0 / 4.0)
    
    @objc static let wh4x3 = ZLImageClipRatio(title: "4 : 3", whRatio: 4.0 / 3.0)
    
    @objc static let wh2x3 = ZLImageClipRatio(title: "2 : 3", whRatio: 2.0 / 3.0)
    
    @objc static let wh3x2 = ZLImageClipRatio(title: "3 : 2", whRatio: 3.0 / 2.0)
    
    @objc static let wh9x16 = ZLImageClipRatio(title: "9 : 16", whRatio: 9.0 / 16.0)
    
    @objc static let wh16x9 = ZLImageClipRatio(title: "16 : 9", whRatio: 16.0 / 9.0)
}
