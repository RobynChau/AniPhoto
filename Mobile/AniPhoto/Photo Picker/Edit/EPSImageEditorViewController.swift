//
//  EPSImageEditorViewController.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/26.
//

import UIKit

public struct EPSClipStatus {
    var angle: CGFloat = 0
    var editRect: CGRect
    var ratio: ZLImageClipRatio?
}

public struct EPSAdjustStatus {
    var brightness: Float = 0
    var contrast: Float = 0
    var saturation: Float = 0
    
    var allValueIsZero: Bool {
        brightness == 0 && contrast == 0 && saturation == 0
    }
}

public class EPSEditImageModel: NSObject {
    public let drawPaths: [EPSDrawPath]
    
    public let mosaicPaths: [EPSMosaicPath]
    
    public let clipStatus: EPSClipStatus
    
    public let adjustStatus: EPSAdjustStatus
    
    public let selectFilter: EPSFilter?
    
    public let stickers: [EPSBaseStickerState]
    
    public let actions: [EPSEditorAction]
    
    public init(
        drawPaths: [EPSDrawPath],
        mosaicPaths: [EPSMosaicPath],
        clipStatus: EPSClipStatus,
        adjustStatus: EPSAdjustStatus,
        selectFilter: EPSFilter,
        stickers: [EPSBaseStickerState],
        actions: [EPSEditorAction]
    ) {
        self.drawPaths = drawPaths
        self.mosaicPaths = mosaicPaths
        self.clipStatus = clipStatus
        self.adjustStatus = adjustStatus
        self.selectFilter = selectFilter
        self.stickers = stickers
        self.actions = actions
        super.init()
    }
}

@objcMembers
public class EPSImageEditorViewController: UIViewController {
    static let maxDrawLineImageWidth: CGFloat = 600
    
    static let shadowColorFrom = UIColor.black.withAlphaComponent(0.35).cgColor
    
    static let shadowColorTo = UIColor.clear.cgColor
    
    static let trashCanSize = CGSize(width: 160, height: 80)
    
    private let tools: [EPSImageEditorConfiguration.EditTool]
    
    private let adjustTools: [EPSImageEditorConfiguration.AdjustTool]
    
    private var animate = true
    
    private var originalImage: UIImage
    
    private var editImage: UIImage
    
    private var editImageWithoutAdjust: UIImage
    
    private var editImageAdjustRef: UIImage?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    // Show image.
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: originalImage)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.backgroundColor = .black
        return view
    }()
    
    // Show draw lines.
    private lazy var drawingImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // Show text and image stickers.
    private lazy var stickersContainer = UIView()
    
    // 处理好的马赛克图片
    private var mosaicImage: UIImage?
    
    // 显示马赛克图片的layer
    private var mosaicImageLayer: CALayer?
    
    // 显示马赛克图片的layer的mask
    private var mosaicImageLayerMaskLayer: CAShapeLayer?
    
    private var selectedTool: EPSImageEditorConfiguration.EditTool?
    
    private var selectedAdjustTool: EPSImageEditorConfiguration.AdjustTool?
    
    private lazy var editToolCollectionView: UICollectionView = {
        let layout = EPSCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        EPSEditToolCell.eps.register(view)
        
        return view
    }()
    
    private var drawColorCollectionView: UICollectionView?
    
    private var filterCollectionView: UICollectionView?
    
    private var adjustCollectionView: UICollectionView?
    
    private var adjustSlider: EPSAdjustSlider?
    
    private let drawColors: [UIColor]
    
    private var currentDrawColor = EPSPhotoConfiguration.default().editImageConfiguration.defaultDrawColor
    
    private var drawPaths: [EPSDrawPath]
    
    private var mosaicPaths: [EPSMosaicPath]
    
    private let minimumZoomScale = EPSPhotoConfiguration.default().editImageConfiguration.minimumZoomScale
    
    private var hasAdjustedImage = false
    
    // collectionview 中的添加滤镜的小图
    private var thumbnailFilterImages: [UIImage] = []
    
    // 选择滤镜后对原图添加滤镜后的图片
    private var filterImages: [String: UIImage] = [:]
    
    private var currentFilter: EPSFilter
    
    private var stickers: [EPSBaseStickerView] = []
    
    private var isScrolling = false
    
    private var shouldLayout = true
    
    private var isFirstSetContainerFrame = true
    
    private var imageStickerContainerIsHidden = true
        
    private var currentClipStatus: EPSClipStatus
    
    private var preClipStatus: EPSClipStatus
    
    private var preStickerState: EPSBaseStickerState?
    
    private var currentAdjustStatus: EPSAdjustStatus
    
    private var preAdjustStatus: EPSAdjustStatus
    
    private var editorManager: EPSEditorManager
    
    private lazy var panGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drawAction(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        return pan
    }()
    
    private var toolViewStateTimer: Timer?
    
    /// 是否允许交换图片宽高
    private var shouldSwapSize: Bool {
        currentClipStatus.angle.eps.toPi.truncatingRemainder(dividingBy: .pi) != 0
    }
    
    private lazy var deleteDrawPaths: [EPSDrawPath] = []
    
    private var defaultDrawPathWidth: CGFloat = 0
    
    private var impactFeedback: UIImpactFeedbackGenerator?
    
    // 第一次进入界面时，布局后frame，裁剪dimiss动画使用
    var originalFrame: CGRect = .zero
    
    var imageSize: CGSize {
        if shouldSwapSize {
            return CGSize(width: originalImage.size.height, height: originalImage.size.width)
        } else {
            return originalImage.size
        }
    }
    
    @objc public var drawColViewH: CGFloat = 50
    
    @objc public var filterColViewH: CGFloat = 90
    
    @objc public var adjustColViewH: CGFloat = 60
    
    @objc public lazy var cancelBtn: EPSEnlargeButton = {
        let btn = EPSEnlargeButton(type: .custom)
        btn.titleLabel?.font = EPSLayout.navTitleFont
        btn.setTitleColor(.eps.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        btn.adjustsImageWhenHighlighted = false
        btn.enlargeInset = 30
        return btn
    }()
    
    @objc public lazy var mainScrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .black
        view.minimumZoomScale = minimumZoomScale
        view.maximumZoomScale = 3
        view.delegate = self
        return view
    }()
    
    // 上方渐变阴影层
    @objc public lazy var topShadowView = UIView()
    
    @objc public lazy var topShadowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [EPSImageEditorViewController.shadowColorFrom, EPSImageEditorViewController.shadowColorTo]
        layer.locations = [0, 1]
        return layer
    }()
     
    // 下方渐变阴影层
    @objc public lazy var bottomShadowView = UIView()
    
    @objc public lazy var bottomShadowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [EPSImageEditorViewController.shadowColorTo, EPSImageEditorViewController.shadowColorFrom]
        layer.locations = [0, 1]
        return layer
    }()
    
    @objc public lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = EPSLayout.bottomToolTitleFont
        btn.backgroundColor = .eps.bottomToolViewBtnNormalBgColor
        btn.setTitle(localLanguageTextValue(.editFinish), for: .normal)
        btn.setTitleColor(.eps.bottomToolViewDoneBtnNormalTitleColor, for: .normal)
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = EPSLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    @objc public lazy var undoBtn: EPSEnlargeButton = {
        let btn = EPSEnlargeButton(type: .custom)
        if isRTL() {
            btn.setImage(
                .eps.getImage("zl_undo")?.imageFlippedForRightToLeftLayoutDirection(),
                for: .normal
            )
            btn.setImage(
                .eps.getImage("zl_undo_disable")?.imageFlippedForRightToLeftLayoutDirection(),
                for: .disabled
            )
        } else {
            btn.setImage(.eps.getImage("zl_undo"), for: .normal)
            btn.setImage(.eps.getImage("zl_undo_disable"), for: .disabled)
        }
        
        btn.adjustsImageWhenHighlighted = false
        btn.isEnabled = !editorManager.actions.isEmpty
        btn.enlargeInset = 8
        btn.addTarget(self, action: #selector(undoBtnClick), for: .touchUpInside)
        return btn
    }()
    
    @objc public lazy var redoBtn: EPSEnlargeButton = {
        let btn = EPSEnlargeButton(type: .custom)
        if isRTL() {
            btn.setImage(
                .eps.getImage("zl_redo")?.imageFlippedForRightToLeftLayoutDirection(),
                for: .normal
            )
            btn.setImage(
                .eps.getImage("zl_redo_disable")?.imageFlippedForRightToLeftLayoutDirection(),
                for: .disabled
            )
        } else {
            btn.setImage(.eps.getImage("zl_redo"), for: .normal)
            btn.setImage(.eps.getImage("zl_redo_disable"), for: .disabled)
        }
        
        btn.adjustsImageWhenHighlighted = false
        btn.isEnabled = editorManager.actions.count != editorManager.redoActions.count
        btn.enlargeInset = 8
        btn.addTarget(self, action: #selector(redoBtnClick), for: .touchUpInside)
        return btn
    }()
    
    @objc public lazy var eraserBtn: EPSEnlargeButton = {
        let btn = EPSEnlargeButton(type: .custom)
        btn.setImage(.eps.getImage("zl_eraser"), for: .normal)
        btn.addTarget(self, action: #selector(eraserBtnClick), for: .touchUpInside)
        btn.isHidden = true
        btn.eps.setCornerRadius(18)
        return btn
    }()
    
    @objc public lazy var eraserBtnBgBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.isHidden = true
        view.eps.setCornerRadius(18)
        return view
    }()
    
    @objc public lazy var eraserLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .eps.rgba(89, 95, 107, 0.8)
        view.isHidden = true
        return view
    }()
    
    @objc public lazy var eraserCircleView: UIImageView = {
        let imageView = UIImageView(image: .eps.getImage("zl_eraser_circle"))
        imageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        imageView.isHidden = true
        return imageView
    }()
    
    @objc public lazy var trashCanView: UIView = {
        let view = UIView()
        view.backgroundColor = .eps.trashCanBackgroundNormalColor
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    @objc public lazy var trashCanImgView = UIImageView(image: .eps.getImage("zl_ashbin"), highlightedImage: .eps.getImage("zl_ashbin_open"))
    
    @objc public var drawLineWidth: CGFloat = 6
    
    @objc public var mosaicLineWidth: CGFloat = 25
    
    @objc public var editFinishBlock: ((UIImage, EPSEditImageModel?) -> Void)?
    
    @objc public var cancelEditBlock: (() -> Void)?
    
    override public var prefersStatusBarHidden: Bool { true }
    
    override public var prefersHomeIndicatorAutoHidden: Bool { true }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        deviceIsiPhone() ? .portrait : .all
    }
    
    deinit {
        cleanToolViewStateTimer()
        eps_debugPrint("EPSImageEditorViewController deinit")
    }
    
    @objc public class func showEditImageVC(
        parentVC: UIViewController?,
        animate: Bool = false,
        image: UIImage,
        editModel: EPSEditImageModel? = nil,
        cancel: (() -> Void)? = nil,
        completion: ((UIImage, EPSEditImageModel?) -> Void)?
    ) {
        let tools = EPSPhotoConfiguration.default().editImageConfiguration.tools
        let editConfig = EPSPhotoConfiguration.default().editImageConfiguration
        
        if editConfig.showClipDirectlyIfOnlyHasClipTool,
           tools.count == 1,
           tools.contains(.clip) {
            let vc = EPSClipImageViewController(
                image: image,
                status: editModel?.clipStatus ?? EPSClipStatus(editRect: CGRect(origin: .zero, size: image.size))
            )
            vc.clipDoneBlock = { angle, editRect, ratio in
                let model = EPSEditImageModel(
                    drawPaths: [],
                    mosaicPaths: [],
                    clipStatus: EPSClipStatus(angle: angle, editRect: editRect, ratio: ratio),
                    adjustStatus: EPSAdjustStatus(),
                    selectFilter: .normal,
                    stickers: [],
                    actions: []
                )
                completion?(image.eps.clipImage(angle: angle, editRect: editRect, isCircle: ratio.isCircle), model)
            }
            vc.cancelClipBlock = cancel
            vc.animate = animate
            vc.modalPresentationStyle = .fullScreen
            parentVC?.present(vc, animated: animate, completion: nil)
        } else {
            let vc = EPSImageEditorViewController(image: image, editModel: editModel)
            vc.editFinishBlock = { ei, editImageModel in
                completion?(ei, editImageModel)
            }
            vc.cancelEditBlock = cancel
            vc.animate = animate
            vc.modalPresentationStyle = .fullScreen
            parentVC?.present(vc, animated: animate, completion: nil)
        }
    }
    
    @objc public init(image: UIImage, editModel: EPSEditImageModel? = nil) {
        var image = image
        if image.scale != 1,
           let cgImage = image.cgImage {
            image = image.eps.resize_vI(
                CGSize(width: cgImage.width, height: cgImage.height),
                scale: 1
            ) ?? image
        }
        
        let editConfig = EPSPhotoConfiguration.default().editImageConfiguration
        
        originalImage = image.eps.fixOrientation()
        editImage = originalImage
        editImageWithoutAdjust = originalImage
        currentClipStatus = editModel?.clipStatus ?? EPSClipStatus(editRect: CGRect(origin: .zero, size: image.size))
        preClipStatus = currentClipStatus
        drawColors = editConfig.drawColors
        currentFilter = editModel?.selectFilter ?? .normal
        drawPaths = editModel?.drawPaths ?? []
        mosaicPaths = editModel?.mosaicPaths ?? []
        currentAdjustStatus = editModel?.adjustStatus ?? EPSAdjustStatus()
        preAdjustStatus = currentAdjustStatus
        
        var ts = editConfig.tools
        editConfig.imageStickerContainerView = EPSImageStickerContainerView()
        if ts.contains(.imageSticker), editConfig.imageStickerContainerView == nil {
            ts.removeAll { $0 == .imageSticker }
        }
        tools = ts
        adjustTools = editConfig.adjustTools
        selectedAdjustTool = editConfig.adjustTools.first
        editorManager = EPSEditorManager(actions: editModel?.actions ?? [])
        
        super.init(nibName: nil, bundle: nil)
        
        editorManager.delegate = self
        
        if !drawColors.contains(currentDrawColor) {
            currentDrawColor = drawColors.first!
        }
        
        stickers = editModel?.stickers.compactMap {
            EPSBaseStickerView.initWithState($0)
        } ?? []
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        rotationImageView()
        if tools.contains(.filter) {
            generateFilterImages()
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard tools.contains(.draw) else { return }
        
        var size = drawingImageView.frame.size
        if shouldSwapSize {
            swap(&size.width, &size.height)
        }
        
        var toImageScale = EPSImageEditorViewController.maxDrawLineImageWidth / size.width
        if editImage.size.width / editImage.size.height > 1 {
            toImageScale = EPSImageEditorViewController.maxDrawLineImageWidth / size.height
        }
        
        let width = drawLineWidth / mainScrollView.zoomScale * toImageScale
        defaultDrawPathWidth = width
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard shouldLayout else {
            return
        }
        shouldLayout = false
        eps_debugPrint("edit image layout subviews")
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        insets.top = max(20, insets.top)
        
        mainScrollView.frame = view.bounds
        resetContainerViewFrame()
        
        topShadowView.frame = CGRect(x: 0, y: 0, width: view.eps.width, height: 150)
        topShadowLayer.frame = topShadowView.bounds
        let cancelBtnW = localLanguageTextValue(.cancel)
            .eps.boundingRect(
                font: EPSLayout.bottomToolTitleFont,
                limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 28)
            ).width
        if isRTL() {
            cancelBtn.frame = CGRect(x: view.eps.width - 20 - 28, y: insets.top, width: cancelBtnW, height: 30)
            redoBtn.frame = CGRect(x: 15, y: insets.top, width: 30, height: 30)
            undoBtn.frame = CGRect(x: redoBtn.eps.right + 15, y: insets.top, width: 30, height: 30)
        } else {
            cancelBtn.frame = CGRect(x: 20, y: insets.top, width: cancelBtnW, height: 30)
            redoBtn.frame = CGRect(x: view.eps.width - 15 - 30, y: insets.top, width: 30, height: 30)
            undoBtn.frame = CGRect(x: redoBtn.eps.left - 15 - 30, y: insets.top, width: 30, height: 30)
        }
        
        bottomShadowView.frame = CGRect(x: 0, y: view.eps.height - 150 - insets.bottom, width: view.eps.width, height: 150 + insets.bottom)
        bottomShadowLayer.frame = bottomShadowView.bounds
        
        eraserBtn.frame = CGRect(x: 20, y: 30 + (drawColViewH - 36) / 2, width: 36, height: 36)
        eraserBtnBgBlurView.frame = eraserBtn.frame
        eraserLineView.frame = CGRect(x: eraserBtn.eps.right + 11, y: eraserBtn.frame.midY - 10, width: 1, height: 20)
        drawColorCollectionView?.frame = CGRect(x: eraserLineView.eps.right + 11, y: 30, width: view.eps.width - eraserLineView.eps.right - 31, height: drawColViewH)
        
        adjustCollectionView?.frame = CGRect(x: 20, y: 20, width: view.eps.width - 40, height: adjustColViewH)
        if EPSPhotoUIConfiguration.default().adjustSliderType == .vertical {
            adjustSlider?.frame = CGRect(x: view.eps.width - 60, y: view.eps.height / 2 - 100, width: 60, height: 200)
        } else {
            let sliderHeight: CGFloat = 60
            let sliderWidth = UIDevice.current.userInterfaceIdiom == .phone ? view.eps.width - 100 : view.eps.width / 2
            adjustSlider?.frame = CGRect(
                x: (view.eps.width - sliderWidth) / 2,
                y: bottomShadowView.eps.top - sliderHeight,
                width: sliderWidth,
                height: sliderHeight
            )
        }
        
        filterCollectionView?.frame = CGRect(x: 20, y: 0, width: view.eps.width - 40, height: filterColViewH)
        
        trashCanView.frame = CGRect(
            x: (view.eps.width - Self.trashCanSize.width) / 2,
            y: view.eps.height - Self.trashCanSize.height - 40,
            width: Self.trashCanSize.width,
            height: Self.trashCanSize.height
        )
        
        trashCanImgView.frame = CGRect(
            x: (Self.trashCanSize.width - 25) / 2,
            y: 15,
            width: 25,
            height: 25
        )
        
        let toolY: CGFloat = 95
        
        let doneBtnH = EPSLayout.bottomToolBtnH
        let doneBtnW = localLanguageTextValue(.editFinish).eps.boundingRect(font: EPSLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: doneBtnH)).width + 20
        doneBtn.frame = CGRect(x: view.eps.width - 20 - doneBtnW, y: toolY - 2, width: doneBtnW, height: doneBtnH)
        
        editToolCollectionView.frame = CGRect(x: 20, y: toolY, width: view.eps.width - 20 - 20 - doneBtnW - 20, height: 30)
        
        if !drawPaths.isEmpty {
            drawLine()
        }
        if !mosaicPaths.isEmpty {
            generateNewMosaicImage()
        }
        
        if let index = drawColors.firstIndex(where: { $0 == self.currentDrawColor }) {
            drawColorCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
        
        let contentRatio = mainScrollView.contentSize.width / mainScrollView.contentSize.height
        let screenRatio = mainScrollView.bounds.size.width / mainScrollView.bounds.size.height
        if abs(contentRatio - screenRatio) < 0.01 {
            mainScrollView.setZoomScale(mainScrollView.minimumZoomScale, animated: true)
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        shouldLayout = true
    }

    private func generateFilterImages() {
        let size: CGSize
        let ratio = (originalImage.size.width / originalImage.size.height)
        let fixLength: CGFloat = 200
        if ratio >= 1 {
            size = CGSize(width: fixLength * ratio, height: fixLength)
        } else {
            size = CGSize(width: fixLength, height: fixLength / ratio)
        }
        let thumbnailImage = originalImage.eps.resize_vI(size) ?? originalImage
        
        DispatchQueue.global().async {
            let filters = EPSPhotoConfiguration.default().editImageConfiguration.filters
            self.thumbnailFilterImages = filters.map { $0.applier?(thumbnailImage) ?? thumbnailImage }
            
            EPSMainAsync {
                self.filterCollectionView?.reloadData()
                self.filterCollectionView?.performBatchUpdates {} completion: { _ in
                    if let index = filters.firstIndex(where: { $0 == self.currentFilter }) {
                        self.filterCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
                    }
                }
            }
        }
    }
    
    private func resetContainerViewFrame() {
        mainScrollView.setZoomScale(1, animated: true)
        imageView.image = editImage
        let editRect = currentClipStatus.editRect
        
        let editSize = editRect.size
        let scrollViewSize = mainScrollView.frame.size
        let ratio = min(scrollViewSize.width / editSize.width, scrollViewSize.height / editSize.height)
        let w = ratio * editSize.width * mainScrollView.zoomScale
        let h = ratio * editSize.height * mainScrollView.zoomScale
        
        let imageRatio = originalImage.size.width / originalImage.size.height
        let y: CGFloat
        // 从相机进入，且竖屏拍照，才做适配
        if isFirstSetContainerFrame,
           presentingViewController is EPSCustomCamera,
           imageRatio < 1 {
            let cameraRatio: CGFloat = 16 / 9
            let layerH = min(view.eps.width * cameraRatio, view.eps.height)
            
            if isSmallScreen() {
                y = deviceIsFringeScreen() ? min(94, view.eps.height - layerH) : 0
            } else {
                y = 0
            }
        } else {
            y = max(0, (scrollViewSize.height - h) / 2)
        }
        
        isFirstSetContainerFrame = false
        
        containerView.frame = CGRect(x: max(0, (scrollViewSize.width - w) / 2), y: y, width: w, height: h)
        mainScrollView.contentSize = containerView.frame.size

        if currentClipStatus.ratio?.isCircle == true {
            let mask = CAShapeLayer()
            let path = UIBezierPath(arcCenter: CGPoint(x: w / 2, y: h / 2), radius: w / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            mask.path = path.cgPath
            containerView.layer.mask = mask
        } else {
            containerView.layer.mask = nil
        }
        let scaleImageOrigin = CGPoint(x: -editRect.origin.x * ratio, y: -editRect.origin.y * ratio)
        let scaleImageSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
        imageView.frame = CGRect(origin: scaleImageOrigin, size: scaleImageSize)
        mosaicImageLayer?.frame = imageView.bounds
        mosaicImageLayerMaskLayer?.frame = imageView.bounds
        drawingImageView.frame = imageView.frame
        stickersContainer.frame = imageView.frame
        
        // 针对于长图的优化
        if (editRect.height / editRect.width) > (view.frame.height / view.frame.width * 1.1) {
            let widthScale = view.frame.width / w
            mainScrollView.maximumZoomScale = widthScale
            mainScrollView.zoomScale = widthScale
            mainScrollView.contentOffset = .zero
        } else if editRect.width / editRect.height > 1 {
            mainScrollView.maximumZoomScale = max(3, view.frame.height / h)
        }
        
        originalFrame = view.convert(containerView.frame, from: mainScrollView)
        isScrolling = false
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(drawingImageView)
        containerView.addSubview(stickersContainer)
        
        topShadowView.layer.addSublayer(topShadowLayer)
        view.addSubview(topShadowView)
        topShadowView.addSubview(cancelBtn)
        topShadowView.addSubview(undoBtn)
        topShadowView.addSubview(redoBtn)
        
        bottomShadowView.layer.addSublayer(bottomShadowLayer)
        view.addSubview(bottomShadowView)
        bottomShadowView.addSubview(editToolCollectionView)
        bottomShadowView.addSubview(doneBtn)
        
        if tools.contains(.draw) {
            bottomShadowView.addSubview(eraserBtnBgBlurView)
            bottomShadowView.addSubview(eraserBtn)
            bottomShadowView.addSubview(eraserLineView)
            containerView.addSubview(eraserCircleView)
            
            impactFeedback = UIImpactFeedbackGenerator(style: .light)
            
            let drawColorLayout = EPSCollectionViewFlowLayout()
            let drawColorItemWidth: CGFloat = 36
            drawColorLayout.itemSize = CGSize(width: drawColorItemWidth, height: drawColorItemWidth)
            drawColorLayout.minimumLineSpacing = 0
            drawColorLayout.minimumInteritemSpacing = 0
            drawColorLayout.scrollDirection = .horizontal
            let drawColorTopBottomInset = (drawColViewH - drawColorItemWidth) / 2
            drawColorLayout.sectionInset = UIEdgeInsets(top: drawColorTopBottomInset, left: 0, bottom: drawColorTopBottomInset, right: 0)
            
            let drawCV = UICollectionView(frame: .zero, collectionViewLayout: drawColorLayout)
            drawCV.backgroundColor = .clear
            drawCV.delegate = self
            drawCV.dataSource = self
            drawCV.isHidden = true
            bottomShadowView.addSubview(drawCV)
            
            ZLDrawColorCell.eps.register(drawCV)
            drawColorCollectionView = drawCV
        }
        
        if tools.contains(.filter) {
            if let applier = currentFilter.applier {
                let image = applier(originalImage)
                editImage = image
                editImageWithoutAdjust = image
                filterImages[currentFilter.name] = image
            }
            
            let filterLayout = EPSCollectionViewFlowLayout()
            filterLayout.itemSize = CGSize(width: filterColViewH - 30, height: filterColViewH - 10)
            filterLayout.minimumLineSpacing = 15
            filterLayout.minimumInteritemSpacing = 15
            filterLayout.scrollDirection = .horizontal
            filterLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
            
            let filterCV = UICollectionView(frame: .zero, collectionViewLayout: filterLayout)
            filterCV.backgroundColor = .clear
            filterCV.delegate = self
            filterCV.dataSource = self
            filterCV.isHidden = true
            bottomShadowView.addSubview(filterCV)
            
            EPSFilterImageCell.eps.register(filterCV)
            filterCollectionView = filterCV
        }
        
        if tools.contains(.adjust) {
            editImage = editImage.eps.adjust(
                brightness: currentAdjustStatus.brightness,
                contrast: currentAdjustStatus.contrast,
                saturation: currentAdjustStatus.saturation
            ) ?? editImage
            
            let adjustLayout = EPSCollectionViewFlowLayout()
            adjustLayout.itemSize = CGSize(width: adjustColViewH, height: adjustColViewH)
            adjustLayout.minimumLineSpacing = 10
            adjustLayout.minimumInteritemSpacing = 10
            adjustLayout.scrollDirection = .horizontal
            
            let adjustCV = UICollectionView(frame: .zero, collectionViewLayout: adjustLayout)
            adjustCV.backgroundColor = .clear
            adjustCV.delegate = self
            adjustCV.dataSource = self
            adjustCV.isHidden = true
            adjustCV.showsHorizontalScrollIndicator = false
            bottomShadowView.addSubview(adjustCV)
            
            EPSAdjustToolCell.eps.register(adjustCV)
            adjustCollectionView = adjustCV
            
            adjustSlider = EPSAdjustSlider()
            if let selectedAdjustTool = selectedAdjustTool {
                changeAdjustTool(selectedAdjustTool)
            }
            adjustSlider?.beginAdjust = { [weak self] in
                guard let `self` = self else { return }
                self.preAdjustStatus = self.currentAdjustStatus
            }
            adjustSlider?.valueChanged = { [weak self] value in
                self?.adjustValueChanged(value)
            }
            adjustSlider?.endAdjust = { [weak self] in
                guard let `self` = self else { return }
                self.editorManager.storeAction(
                    .adjust(oldStatus: self.preAdjustStatus, newStatus: self.currentAdjustStatus)
                )
                self.hasAdjustedImage = true
            }
            adjustSlider?.isHidden = true
            view.addSubview(adjustSlider!)
        }
        
        view.addSubview(trashCanView)
        trashCanView.addSubview(trashCanImgView)
        
        let asbinTipLabel = UILabel(frame: CGRect(x: 0, y: Self.trashCanSize.height - 34, width: Self.trashCanSize.width, height: 34))
        asbinTipLabel.font = .eps.font(ofSize: 12)
        asbinTipLabel.textAlignment = .center
        asbinTipLabel.textColor = .white
        asbinTipLabel.text = localLanguageTextValue(.textStickerRemoveTips)
        asbinTipLabel.numberOfLines = 2
        asbinTipLabel.lineBreakMode = .byCharWrapping
        trashCanView.addSubview(asbinTipLabel)
        
        if tools.contains(.mosaic) {
            mosaicImage = editImage.eps.mosaicImage()
            
            mosaicImageLayer = CALayer()
            mosaicImageLayer?.contents = mosaicImage?.cgImage
            imageView.layer.addSublayer(mosaicImageLayer!)
            
            mosaicImageLayerMaskLayer = CAShapeLayer()
            mosaicImageLayerMaskLayer?.strokeColor = UIColor.blue.cgColor
            mosaicImageLayerMaskLayer?.fillColor = nil
            mosaicImageLayerMaskLayer?.lineCap = .round
            mosaicImageLayerMaskLayer?.lineJoin = .round
            imageView.layer.addSublayer(mosaicImageLayerMaskLayer!)
            
            mosaicImageLayer?.mask = mosaicImageLayerMaskLayer
        }
        
        if tools.contains(.imageSticker) {
            let imageStickerView = EPSPhotoConfiguration.default().editImageConfiguration.imageStickerContainerView
            imageStickerView?.hideBlock = { [weak self] in
                self?.setToolView(show: true)
                self?.imageStickerContainerIsHidden = true
            }
            
            imageStickerView?.selectImageBlock = { [weak self] image in
                self?.addImageStickerView(image)
            }
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGes.delegate = self
        view.addGestureRecognizer(tapGes)
        
        view.addGestureRecognizer(panGes)
        mainScrollView.panGestureRecognizer.require(toFail: panGes)
        
        stickers.forEach { self.addSticker($0) }
    }
    
    private func rotationImageView() {
        let transform = CGAffineTransform(rotationAngle: currentClipStatus.angle.eps.toPi)
        imageView.transform = transform
        drawingImageView.transform = transform
        stickersContainer.transform = transform
    }
    
    @objc private func cancelBtnClick() {
        dismiss(animated: animate) {
            self.cancelEditBlock?()
        }
    }
    
    @objc public func drawBtnClick() {
        let isSelected = selectedTool != .draw
        if isSelected {
            selectedTool = .draw
        } else {
            selectedTool = nil
        }
        
        setDrawViews(hidden: !isSelected)
        setFilterViews(hidden: true)
        setAdjustViews(hidden: true)
    }
    
    @objc private func eraserBtnClick() {
        switchEraserBtnStatus(!eraserBtn.isSelected)
    }
    
    private func switchEraserBtnStatus(_ isSelected: Bool, reloadData: Bool = true) {
        guard eraserBtn.isSelected != isSelected else { return }
        
        eraserBtn.isSelected = isSelected
        eraserBtnBgBlurView.isHidden = !isSelected
        
        if reloadData {
            drawColorCollectionView?.reloadData()
        }
    }
    
    @objc public func clipBtnClick() {
        preClipStatus = currentClipStatus
        
        let currentEditImage = buildImage()
        let vc = EPSClipImageViewController(image: currentEditImage, status: currentClipStatus)
        let rect = mainScrollView.convert(containerView.frame, to: view)
        vc.presentAnimateFrame = rect
        vc.presentAnimateImage = currentEditImage.eps
            .clipImage(
                angle: currentClipStatus.angle,
                editRect: currentClipStatus.editRect,
                isCircle: currentClipStatus.ratio?.isCircle ?? false
            )
        vc.modalPresentationStyle = .fullScreen
        
        vc.clipDoneBlock = { [weak self] angle, editRect, selectRatio in
            guard let `self` = self else { return }
            
            self.clipImage(status: EPSClipStatus(angle: angle, editRect: editRect, ratio: selectRatio))
            self.editorManager.storeAction(.clip(oldStatus: self.preClipStatus, newStatus: self.currentClipStatus))
        }
        
        vc.cancelClipBlock = { [weak self] () in
            self?.resetContainerViewFrame()
        }
        
        present(vc, animated: false) {
            self.mainScrollView.alpha = 0
            self.topShadowView.alpha = 0
            self.bottomShadowView.alpha = 0
            self.adjustSlider?.alpha = 0
        }
        
        selectedTool = nil
        setDrawViews(hidden: true)
        setFilterViews(hidden: true)
        setAdjustViews(hidden: true)
    }
    
    private func clipImage(status: EPSClipStatus) {
        let oldAngle = currentClipStatus.angle
        let oldContainerSize = stickersContainer.frame.size
        if oldAngle != status.angle {
            currentClipStatus.angle = status.angle
            rotationImageView()
        }
        
        currentClipStatus.editRect = status.editRect
        currentClipStatus.ratio = status.ratio
        resetContainerViewFrame()
        recalculateStickersFrame(oldContainerSize, oldAngle, status.angle)
    }
    
    @objc public func imageStickerBtnClick() {
        EPSPhotoConfiguration.default().editImageConfiguration.imageStickerContainerView?.show(in: view)
        setToolView(show: false)
        imageStickerContainerIsHidden = false
        
        selectedTool = nil
        setDrawViews(hidden: true)
        setFilterViews(hidden: true)
        setAdjustViews(hidden: true)
    }
    
    @objc public func textStickerBtnClick() {
        showInputTextVC(
            font: EPSPhotoConfiguration.default().editImageConfiguration.textStickerDefaultFont
        ) { [weak self] text, textColor, font, image, style in
            guard !text.isEmpty, let image = image else { return }
            self?.addTextStickersView(text, textColor: textColor, font: font, image: image, style: style)
        }
        
        selectedTool = nil
        setDrawViews(hidden: true)
        setFilterViews(hidden: true)
        setAdjustViews(hidden: true)
    }
    
    @objc public func mosaicBtnClick() {
        let isSelected = selectedTool != .mosaic
        if isSelected {
            selectedTool = .mosaic
        } else {
            selectedTool = nil
        }
        
        generateNewMosaicLayerIfAdjust()
        setDrawViews(hidden: true)
        setFilterViews(hidden: true)
        setAdjustViews(hidden: true)
    }
    
    @objc public func filterBtnClick() {
        let isSelected = selectedTool != .filter
        if isSelected {
            selectedTool = .filter
        } else {
            selectedTool = nil
        }
        
        setDrawViews(hidden: true)
        setFilterViews(hidden: !isSelected)
        setAdjustViews(hidden: true)
    }
    
    @objc public func adjustBtnClick() {
        let isSelected = selectedTool != .adjust
        if isSelected {
            selectedTool = .adjust
        } else {
            selectedTool = nil
        }
        
        generateAdjustImageRef()
        setDrawViews(hidden: true)
        setFilterViews(hidden: true)
        setAdjustViews(hidden: !isSelected)
    }
    
    private func setDrawViews(hidden: Bool) {
        eraserBtn.isHidden = hidden
        eraserBtnBgBlurView.isHidden = hidden || !eraserBtn.isSelected
        eraserLineView.isHidden = hidden
        drawColorCollectionView?.isHidden = hidden
    }
    
    private func setFilterViews(hidden: Bool) {
        filterCollectionView?.isHidden = hidden
    }
    
    private func setAdjustViews(hidden: Bool) {
        adjustCollectionView?.isHidden = hidden
        adjustSlider?.isHidden = hidden
    }
    
    private func changeAdjustTool(_ tool: EPSImageEditorConfiguration.AdjustTool) {
        selectedAdjustTool = tool
        
        switch tool {
        case .brightness:
            adjustSlider?.value = currentAdjustStatus.brightness
        case .contrast:
            adjustSlider?.value = currentAdjustStatus.contrast
        case .saturation:
            adjustSlider?.value = currentAdjustStatus.saturation
        }
    }
    
    @objc private func doneBtnClick() {
        var stickerStates: [EPSBaseStickerState] = []
        for view in stickersContainer.subviews {
            guard let view = view as? EPSBaseStickerView else { continue }
            stickerStates.append(view.state)
        }
        
        var hasEdit = true
        if drawPaths.isEmpty,
           currentClipStatus.editRect.size == imageSize,
           currentClipStatus.angle == 0,
           mosaicPaths.isEmpty,
           stickerStates.isEmpty,
           currentFilter.applier == nil,
           currentAdjustStatus.allValueIsZero {
            hasEdit = false
        }
        
        var resImage = originalImage
        var editModel: EPSEditImageModel?
        
        func callback() {
            dismiss(animated: animate) {
                self.editFinishBlock?(resImage, editModel)
            }
        }
        
        guard hasEdit else {
            callback()
            return
        }
        
        let hud = EPSProgressHUD.show(toast: .processing)
        DispatchQueue.main.async { [self] in
            resImage = buildImage()
            resImage = resImage.eps
                .clipImage(
                    angle: currentClipStatus.angle,
                    editRect: currentClipStatus.editRect,
                    isCircle: currentClipStatus.ratio?.isCircle ?? false
                )
            editModel = EPSEditImageModel(
                drawPaths: drawPaths,
                mosaicPaths: mosaicPaths,
                clipStatus: currentClipStatus,
                adjustStatus: currentAdjustStatus,
                selectFilter: currentFilter,
                stickers: stickerStates,
                actions: editorManager.actions
            )

            hud.hide()
            callback()
        }
    }
    
    @objc private func undoBtnClick() {
        editorManager.undoAction()
    }
    
    @objc private func redoBtnClick() {
        editorManager.redoAction()
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        if bottomShadowView.alpha == 1 {
            setToolView(show: false)
        } else {
            setToolView(show: true)
        }
    }
    
    @objc private func drawAction(_ pan: UIPanGestureRecognizer) {
        // 橡皮擦
        if selectedTool == .draw, eraserBtn.isSelected {
            eraserAction(pan)
            return
        }
        
        if selectedTool == .draw {
            let point = pan.location(in: drawingImageView)
            if pan.state == .began {
                setToolView(show: false)
                
                let originalRatio = min(mainScrollView.frame.width / originalImage.size.width, mainScrollView.frame.height / originalImage.size.height)
                let ratio = min(
                    mainScrollView.frame.width / currentClipStatus.editRect.width,
                    mainScrollView.frame.height / currentClipStatus.editRect.height
                )
                let scale = ratio / originalRatio
                // 缩放到最初的size
                var size = drawingImageView.frame.size
                size.width /= scale
                size.height /= scale
                if shouldSwapSize {
                    swap(&size.width, &size.height)
                }
                
                var toImageScale = EPSImageEditorViewController.maxDrawLineImageWidth / size.width
                if editImage.size.width / editImage.size.height > 1 {
                    toImageScale = EPSImageEditorViewController.maxDrawLineImageWidth / size.height
                }
                
                let path = EPSDrawPath(
                    pathColor: currentDrawColor,
                    pathWidth: drawLineWidth / mainScrollView.zoomScale,
                    defaultLinePath: defaultDrawPathWidth,
                    ratio: ratio / originalRatio / toImageScale,
                    startPoint: point
                )
                drawPaths.append(path)
            } else if pan.state == .changed {
                let path = drawPaths.last
                path?.addLine(to: point)
                drawLine()
            } else if pan.state == .cancelled || pan.state == .ended {
                setToolView(show: true, delay: 0.5)
                
                if let path = drawPaths.last {
                    editorManager.storeAction(.draw(path))
                }
            }
        } else if selectedTool == .mosaic {
            let point = pan.location(in: imageView)
            if pan.state == .began {
                setToolView(show: false)
                
                var actualSize = currentClipStatus.editRect.size
                if shouldSwapSize {
                    swap(&actualSize.width, &actualSize.height)
                }
                let ratio = min(
                    mainScrollView.frame.width / currentClipStatus.editRect.width,
                    mainScrollView.frame.height / currentClipStatus.editRect.height
                )
                
                let pathW = mosaicLineWidth / mainScrollView.zoomScale
                let path = EPSMosaicPath(pathWidth: pathW, ratio: ratio, startPoint: point)
                
                mosaicImageLayerMaskLayer?.lineWidth = pathW
                mosaicImageLayerMaskLayer?.path = path.path.cgPath
                mosaicPaths.append(path)
            } else if pan.state == .changed {
                let path = mosaicPaths.last
                path?.addLine(to: point)
                mosaicImageLayerMaskLayer?.path = path?.path.cgPath
            } else if pan.state == .cancelled || pan.state == .ended {
                setToolView(show: true, delay: 0.5)
                if let path = mosaicPaths.last {
                    editorManager.storeAction(.mosaic(path))
                }
                
                generateNewMosaicImage()
            }
        }
    }
    
    private func eraserAction(_ pan: UIPanGestureRecognizer) {
        // 相对于drawingImageView的point
        let point = pan.location(in: drawingImageView)
        let originalRatio = min(mainScrollView.frame.width / originalImage.size.width, mainScrollView.frame.height / originalImage.size.height)
        let ratio = min(
            mainScrollView.frame.width / currentClipStatus.editRect.width,
            mainScrollView.frame.height / currentClipStatus.editRect.height
        )
        let scale = ratio / originalRatio
        // 缩放到最初的size
        var size = drawingImageView.frame.size
        size.width /= scale
        size.height /= scale
        if shouldSwapSize {
            swap(&size.width, &size.height)
        }
        
        var toImageScale = EPSImageEditorViewController.maxDrawLineImageWidth / size.width
        if editImage.size.width / editImage.size.height > 1 {
            toImageScale = EPSImageEditorViewController.maxDrawLineImageWidth / size.height
        }
        
        let pointScale = ratio / originalRatio / toImageScale
        // 转换为drawPath的point
        let drawPoint = CGPoint(x: point.x / pointScale, y: point.y / pointScale)
        if pan.state == .began {
            eraserCircleView.isHidden = false
            impactFeedback?.prepare()
        }
        
        if pan.state == .began || pan.state == .changed {
            var transform: CGAffineTransform = .identity
            
            let angle = ((Int(currentClipStatus.angle) % 360) + 360) % 360
            let drawingImageViewSize = drawingImageView.frame.size
            if angle == 90 {
                transform = transform.translatedBy(x: 0, y: -drawingImageViewSize.width)
            } else if angle == 180 {
                transform = transform.translatedBy(x: -drawingImageViewSize.width, y: -drawingImageViewSize.height)
            } else if angle == 270 {
                transform = transform.translatedBy(x: -drawingImageViewSize.height, y: 0)
            }
            transform = transform.concatenating(drawingImageView.transform)
            eraserCircleView.center = point.applying(transform)
            
            var needDraw = false
            for path in drawPaths {
                if path.path.contains(drawPoint), !deleteDrawPaths.contains(path) {
                    path.willDelete = true
                    deleteDrawPaths.append(path)
                    needDraw = true
                    impactFeedback?.impactOccurred()
                }
            }
            if needDraw {
                drawLine()
            }
        } else {
            eraserCircleView.isHidden = true
            if !deleteDrawPaths.isEmpty {
                editorManager.storeAction(.eraser(deleteDrawPaths))
                drawPaths.removeAll { deleteDrawPaths.contains($0) }
                deleteDrawPaths.removeAll()
                drawLine()
            }
        }
    }
    
    // 生成一个没有调整参数前的图片
    private func generateAdjustImageRef() {
        editImageAdjustRef = generateNewMosaicImage(inputImage: editImageWithoutAdjust, inputMosaicImage: editImageWithoutAdjust.eps.mosaicImage())
    }
    
    private func adjustValueChanged(_ value: Float) {
        guard let selectedAdjustTool else {
            return
        }
        
        switch selectedAdjustTool {
        case .brightness:
            if currentAdjustStatus.brightness == value {
                return
            }
            
            currentAdjustStatus.brightness = value
        case .contrast:
            if currentAdjustStatus.contrast == value {
                return
            }
            
            currentAdjustStatus.contrast = value
        case .saturation:
            if currentAdjustStatus.saturation == value {
                return
            }
            
            currentAdjustStatus.saturation = value
        }
        
        adjustStatusChanged()
    }
    
    private func adjustStatusChanged() {
        let resultImage = editImageAdjustRef?.eps.adjust(
            brightness: currentAdjustStatus.brightness,
            contrast: currentAdjustStatus.contrast,
            saturation: currentAdjustStatus.saturation
        )
        
        guard let resultImage else { return }
        
        editImage = resultImage
        imageView.image = editImage
    }
    
    private func generateNewMosaicLayerIfAdjust() {
        defer {
            hasAdjustedImage = false
        }
        
        guard tools.contains(.mosaic), hasAdjustedImage else { return }
        
        generateNewMosaicImageLayer()
        
        if !mosaicPaths.isEmpty {
            generateNewMosaicImage()
        }
    }
    
    private func setToolView(show: Bool, delay: TimeInterval? = nil) {
        cleanToolViewStateTimer()
        if let delay = delay {
            toolViewStateTimer = Timer.scheduledTimer(timeInterval: delay, target: EPSWeakProxy(target: self), selector: #selector(setToolViewShow_timerFunc(show:)), userInfo: ["show": show], repeats: false)
            RunLoop.current.add(toolViewStateTimer!, forMode: .common)
        } else {
            setToolViewShow_timerFunc(show: show)
        }
    }
    
    @objc private func setToolViewShow_timerFunc(show: Bool) {
        var flag = show
        if let toolViewStateTimer = toolViewStateTimer {
            let userInfo = toolViewStateTimer.userInfo as? [String: Any]
            flag = userInfo?["show"] as? Bool ?? true
            cleanToolViewStateTimer()
        }
        topShadowView.layer.removeAllAnimations()
        bottomShadowView.layer.removeAllAnimations()
        adjustSlider?.layer.removeAllAnimations()
        if flag {
            UIView.animate(withDuration: 0.25) {
                self.topShadowView.alpha = 1
                self.bottomShadowView.alpha = 1
                self.adjustSlider?.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.topShadowView.alpha = 0
                self.bottomShadowView.alpha = 0
                self.adjustSlider?.alpha = 0
            }
        }
    }
    
    private func cleanToolViewStateTimer() {
        toolViewStateTimer?.invalidate()
        toolViewStateTimer = nil
    }
    
    private func showInputTextVC(_ text: String? = nil, textColor: UIColor? = nil, font: UIFont? = nil, style: ZLInputTextStyle = .normal, completion: @escaping ((String, UIColor, UIFont, UIImage?, ZLInputTextStyle) -> Void)) {
        // Calculate image displayed frame on the screen.
        var r = mainScrollView.convert(view.frame, to: containerView)
        r.origin.x += mainScrollView.contentOffset.x / mainScrollView.zoomScale
        r.origin.y += mainScrollView.contentOffset.y / mainScrollView.zoomScale
        let scale = imageSize.width / imageView.frame.width
        r.origin.x *= scale
        r.origin.y *= scale
        r.size.width *= scale
        r.size.height *= scale
        let isCircle = currentClipStatus.ratio?.isCircle ?? false
        let bgImage = buildImage()
            .eps.clipImage(angle: currentClipStatus.angle, editRect: currentClipStatus.editRect, isCircle: isCircle)
            .eps.clipImage(angle: 0, editRect: r, isCircle: isCircle)
        let vc = EPSInputTextViewController(image: bgImage, text: text, textColor: textColor, font: font, style: style)
        
        vc.endInput = { text, textColor, font, image, style in
            completion(text, textColor, font, image, style)
        }
        
        vc.modalPresentationStyle = .fullScreen
        showDetailViewController(vc, sender: nil)
    }
    
    private func getStickerOriginFrame(_ size: CGSize) -> CGRect {
        let scale = mainScrollView.zoomScale
        // Calculate the display rect of container view.
        let x = (mainScrollView.contentOffset.x - containerView.frame.minX) / scale
        let y = (mainScrollView.contentOffset.y - containerView.frame.minY) / scale
        let w = view.frame.width / scale
        let h = view.frame.height / scale
        // Convert to text stickers container view.
        let r = containerView.convert(CGRect(x: x, y: y, width: w, height: h), to: stickersContainer)
        let originFrame = CGRect(x: r.minX + (r.width - size.width) / 2, y: r.minY + (r.height - size.height) / 2, width: size.width, height: size.height)
        return originFrame
    }
    
    /// Add image sticker
    private func addImageStickerView(_ image: UIImage) {
        let scale = mainScrollView.zoomScale
        let size = EPSImageStickerView.calculateSize(image: image, width: view.frame.width)
        let originFrame = getStickerOriginFrame(size)
        
        let imageSticker = EPSImageStickerView(image: image, originScale: 1 / scale, originAngle: -currentClipStatus.angle, originFrame: originFrame)
        addSticker(imageSticker)
        view.layoutIfNeeded()
        
        editorManager.storeAction(.sticker(oldState: nil, newState: imageSticker.state))
    }
    
    /// Add text sticker
    private func addTextStickersView(_ text: String, textColor: UIColor, font: UIFont, image: UIImage, style: ZLInputTextStyle) {
        guard !text.isEmpty else { return }
        
        let scale = mainScrollView.zoomScale
        let size = EPSTextStickerView.calculateSize(image: image)
        let originFrame = getStickerOriginFrame(size)
        
        let textSticker = EPSTextStickerView(
            text: text,
            textColor: textColor,
            font: font,
            style: style,
            image: image,
            originScale: 1 / scale,
            originAngle: -currentClipStatus.angle,
            originFrame: originFrame
        )
        addSticker(textSticker)
        
        editorManager.storeAction(.sticker(oldState: nil, newState: textSticker.state))
    }
    
    private func addSticker(_ sticker: EPSBaseStickerView) {
        stickersContainer.addSubview(sticker)
        sticker.frame = sticker.originFrame
        configSticker(sticker)
    }
    
    private func removeSticker(id: String?) {
        guard let id else { return }
        
        for sticker in stickersContainer.subviews.reversed() {
            guard let stickerID = (sticker as? EPSBaseStickerView)?.id,
                  stickerID == id else {
                continue
            }
            
            (sticker as? EPSBaseStickerView)?.moveToTrashCan()
            
            break
        }
    }
    
    private func configSticker(_ sticker: EPSBaseStickerView) {
        sticker.delegate = self
        mainScrollView.pinchGestureRecognizer?.require(toFail: sticker.pinchGes)
        mainScrollView.panGestureRecognizer.require(toFail: sticker.panGes)
        panGes.require(toFail: sticker.panGes)
    }
    
    private func recalculateStickersFrame(_ oldSize: CGSize, _ oldAngle: CGFloat, _ newAngle: CGFloat) {
        let currSize = stickersContainer.frame.size
        let scale: CGFloat
        if (newAngle - oldAngle).eps.toPi.truncatingRemainder(dividingBy: .pi) == 0 {
            scale = currSize.width / oldSize.width
        } else {
            scale = currSize.height / oldSize.width
        }
        
        stickersContainer.subviews.forEach { view in
            (view as? EPSStickerViewAdditional)?.addScale(scale)
        }
    }
    
    private func drawLine() {
        let originalRatio = min(mainScrollView.frame.width / originalImage.size.width, mainScrollView.frame.height / originalImage.size.height)
        let ratio = min(
            mainScrollView.frame.width / currentClipStatus.editRect.width,
            mainScrollView.frame.height / currentClipStatus.editRect.height
        )
        let scale = ratio / originalRatio
        // 缩放到最初的size
        var size = drawingImageView.frame.size
        size.width /= scale
        size.height /= scale
        if shouldSwapSize {
            swap(&size.width, &size.height)
        }
        var toImageScale = EPSImageEditorViewController.maxDrawLineImageWidth / size.width
        if editImage.size.width / editImage.size.height > 1 {
            toImageScale = EPSImageEditorViewController.maxDrawLineImageWidth / size.height
        }
        size.width *= toImageScale
        size.height *= toImageScale
        
        
        drawingImageView.image = UIGraphicsImageRenderer.eps.renderImage(size: size) { context in
            context.setAllowsAntialiasing(true)
            context.setShouldAntialias(true)
            for path in drawPaths {
                path.drawPath()
            }
        }
    }
    
    private func changeFilter(_ filter: EPSFilter) {
        func adjustImage(_ image: UIImage) -> UIImage {
            guard tools.contains(.adjust), !currentAdjustStatus.allValueIsZero else {
                return image
            }
            
            return image.eps.adjust(
                brightness: currentAdjustStatus.brightness,
                contrast: currentAdjustStatus.contrast,
                saturation: currentAdjustStatus.saturation
            ) ?? image
        }
        
        currentFilter = filter
        if let image = filterImages[currentFilter.name] {
            editImage = adjustImage(image)
            editImageWithoutAdjust = image
        } else {
            let image = currentFilter.applier?(originalImage) ?? originalImage
            editImage = adjustImage(image)
            editImageWithoutAdjust = image
            filterImages[currentFilter.name] = image
        }
        
        if tools.contains(.mosaic) {
            generateNewMosaicImageLayer()
            
            if mosaicPaths.isEmpty {
                imageView.image = editImage
            } else {
                generateNewMosaicImage()
            }
        } else {
            imageView.image = editImage
        }
    }
    
    private func generateNewMosaicImageLayer() {
        mosaicImage = editImage.eps.mosaicImage()
        
        mosaicImageLayer?.removeFromSuperlayer()
        
        mosaicImageLayer = CALayer()
        mosaicImageLayer?.frame = imageView.bounds
        mosaicImageLayer?.contents = mosaicImage?.cgImage
        imageView.layer.insertSublayer(mosaicImageLayer!, below: mosaicImageLayerMaskLayer)
        
        mosaicImageLayer?.mask = mosaicImageLayerMaskLayer
    }
    
    /// 传入inputImage 和 inputMosaicImage则代表仅想要获取新生成的mosaic图片
    @discardableResult
    private func generateNewMosaicImage(inputImage: UIImage? = nil, inputMosaicImage: UIImage? = nil) -> UIImage? {
        let renderRect = CGRect(origin: .zero, size: originalImage.size)
        
        var midImage = UIGraphicsImageRenderer.eps.renderImage(size: originalImage.size) { format in
            format.scale = self.originalImage.scale
        } imageActions: { context in
            if inputImage != nil {
                inputImage?.draw(in: renderRect)
            } else {
                var drawImage: UIImage?
                if tools.contains(.filter), let image = filterImages[currentFilter.name] {
                    drawImage = image
                } else {
                    drawImage = originalImage
                }
                
                if tools.contains(.adjust), !currentAdjustStatus.allValueIsZero {
                    drawImage = drawImage?.eps.adjust(
                        brightness: currentAdjustStatus.brightness,
                        contrast: currentAdjustStatus.contrast,
                        saturation: currentAdjustStatus.saturation
                    )
                }
                
                drawImage?.draw(in: renderRect)
            }
            
            mosaicPaths.forEach { path in
                context.move(to: path.startPoint)
                path.linePoints.forEach { point in
                    context.addLine(to: point)
                }
                context.setLineWidth(path.path.lineWidth / path.ratio)
                context.setLineCap(.round)
                context.setLineJoin(.round)
                context.setBlendMode(.clear)
                context.strokePath()
            }
        }
        
        guard let midCgImage = midImage.cgImage else { return nil }
        midImage = UIImage(cgImage: midCgImage, scale: editImage.scale, orientation: .up)
        
        let temp = UIGraphicsImageRenderer.eps.renderImage(size: originalImage.size) { format in
            format.scale = self.originalImage.scale
        } imageActions: { _ in
            // 由于生成的mosaic图片可能在边缘区域出现空白部分，导致合成后会有黑边，所以在最下面先画一张原图
            originalImage.draw(in: renderRect)
            (inputMosaicImage ?? mosaicImage)?.draw(in: renderRect)
            midImage.draw(in: renderRect)
        }
        
        guard let cgi = temp.cgImage else { return nil }
        let image = UIImage(cgImage: cgi, scale: editImage.scale, orientation: .up)
        
        if inputImage != nil {
            return image
        }
        
        editImage = image
        imageView.image = image
        mosaicImageLayerMaskLayer?.path = nil
        
        return image
    }
    
    private func buildImage() -> UIImage {
        let image = UIGraphicsImageRenderer.eps.renderImage(size: editImage.size) { format in
            format.scale = self.editImage.scale
        } imageActions: { context in
            editImage.draw(at: .zero)
            drawingImageView.image?.draw(in: CGRect(origin: .zero, size: originalImage.size))
            
            if !stickersContainer.subviews.isEmpty {
                let scale = imageSize.width / stickersContainer.frame.width
                stickersContainer.subviews.forEach { view in
                    (view as? EPSStickerViewAdditional)?.resetState()
                }
                context.concatenate(CGAffineTransform(scaleX: scale, y: scale))
                stickersContainer.layer.render(in: context)
                context.concatenate(CGAffineTransform(scaleX: 1 / scale, y: 1 / scale))
            }
        }
        
        guard let cgi = image.cgImage else {
            return editImage
        }
        return UIImage(cgImage: cgi, scale: editImage.scale, orientation: .up)
    }
    
    func finishClipDismissAnimate() {
        mainScrollView.alpha = 1
        UIView.animate(withDuration: 0.1) {
            self.topShadowView.alpha = 1
            self.bottomShadowView.alpha = 1
            self.adjustSlider?.alpha = 1
        }
    }

    public func updateToRealImage(inputImage : UIImage) {
        originalImage = inputImage.eps.fixOrientation()
        editImage = originalImage
        editImageWithoutAdjust = originalImage
        self.clipImage(status: EPSClipStatus(editRect: CGRect(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height)))
    }
}

// MARK: UIGestureRecognizerDelegate

extension EPSImageEditorViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard imageStickerContainerIsHidden else {
            return false
        }
        if gestureRecognizer is UITapGestureRecognizer {
            if bottomShadowView.alpha == 1 {
                let p = gestureRecognizer.location(in: view)
                return !bottomShadowView.frame.contains(p)
            } else {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            guard let selectedTool = selectedTool else {
                return false
            }
            return (selectedTool == .draw || selectedTool == .mosaic) && !isScrolling
        }
        
        return true
    }
}

// MARK: scroll view delegate

extension EPSImageEditorViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return containerView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        containerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isScrolling = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == mainScrollView else {
            return
        }
        isScrolling = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == mainScrollView else {
            return
        }
        isScrolling = decelerate
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == mainScrollView else {
            return
        }
        isScrolling = false
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView == mainScrollView else {
            return
        }
        isScrolling = false
    }
}

// MARK: collection view data source & delegate

extension EPSImageEditorViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == editToolCollectionView {
            return tools.count
        } else if collectionView == drawColorCollectionView {
            return drawColors.count
        } else if collectionView == filterCollectionView {
            return thumbnailFilterImages.count
        } else {
            return adjustTools.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == editToolCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSEditToolCell.eps.identifier, for: indexPath) as! EPSEditToolCell
            
            let toolType = tools[indexPath.row]
            cell.icon.isHighlighted = false
            cell.toolType = toolType
            cell.icon.isHighlighted = toolType == selectedTool
            
            return cell
        } else if collectionView == drawColorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.eps.identifier, for: indexPath) as! ZLDrawColorCell
            
            let c = drawColors[indexPath.row]
            cell.color = c
            if c == currentDrawColor, !eraserBtn.isSelected {
                cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
            } else {
                cell.bgWhiteView.layer.transform = CATransform3DIdentity
            }
            
            return cell
        } else if collectionView == filterCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSFilterImageCell.eps.identifier, for: indexPath) as! EPSFilterImageCell
            
            let image = thumbnailFilterImages[indexPath.row]
            let filter = EPSPhotoConfiguration.default().editImageConfiguration.filters[indexPath.row]
            
            cell.nameLabel.text = filter.name
            cell.imageView.image = image
            
            if currentFilter === filter {
                cell.nameLabel.textColor = .eps.imageEditorToolTitleTintColor
            } else {
                cell.nameLabel.textColor = .eps.imageEditorToolTitleNormalColor
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSAdjustToolCell.eps.identifier, for: indexPath) as! EPSAdjustToolCell
            
            let tool = adjustTools[indexPath.row]
            
            cell.imageView.isHighlighted = false
            cell.adjustTool = tool
            let isSelected = tool == selectedAdjustTool
            cell.imageView.isHighlighted = isSelected
            
            if isSelected {
                cell.nameLabel.textColor = .eps.imageEditorToolTitleTintColor
            } else {
                cell.nameLabel.textColor = .eps.imageEditorToolTitleNormalColor
            }
            
            return cell
        }
    }

    @objc public func selectTool(atIndex : Int) {
        editToolCollectionView.selectItem(at: IndexPath(item: atIndex, section: 0), animated: false, scrollPosition: .left)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == editToolCollectionView {
            let toolType = tools[indexPath.row]
            switch toolType {
            case .draw:
                drawBtnClick()
            case .clip:
                clipBtnClick()
            case .imageSticker:
                imageStickerBtnClick()
            case .textSticker:
                textStickerBtnClick()
            case .mosaic:
                mosaicBtnClick()
            case .filter:
                filterBtnClick()
            case .adjust:
                adjustBtnClick()
            }
        } else if collectionView == drawColorCollectionView {
            currentDrawColor = drawColors[indexPath.row]
            switchEraserBtnStatus(false, reloadData: false)
        } else if collectionView == filterCollectionView {
            let filter = EPSPhotoConfiguration.default().editImageConfiguration.filters[indexPath.row]
            editorManager.storeAction(.filter(oldFilter: currentFilter, newFilter: filter))
            changeFilter(filter)
        } else {
            let tool = adjustTools[indexPath.row]
            if tool != selectedAdjustTool {
                changeAdjustTool(tool)
            }
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
}

// MARK: ZLTextStickerViewDelegate

extension EPSImageEditorViewController: EPSStickerViewDelegate {
    func stickerBeginOperation(_ sticker: EPSBaseStickerView) {
        preStickerState = sticker.state
        
        setToolView(show: false)
        trashCanView.layer.removeAllAnimations()
        trashCanView.isHidden = false
        var frame = trashCanView.frame
        let diff = view.frame.height - frame.minY
        frame.origin.y += diff
        trashCanView.frame = frame
        frame.origin.y -= diff
        UIView.animate(withDuration: 0.25) {
            self.trashCanView.frame = frame
        }
        
        stickersContainer.subviews.forEach { view in
            if view !== sticker {
                (view as? EPSStickerViewAdditional)?.resetState()
                (view as? EPSStickerViewAdditional)?.isGestureEnabled = false
            }
        }
    }
    
    func stickerOnOperation(_ sticker: EPSBaseStickerView, panGes: UIPanGestureRecognizer) {
        let point = panGes.location(in: view)
        if trashCanView.frame.contains(point) {
            trashCanView.backgroundColor = .eps.trashCanBackgroundTintColor
            trashCanImgView.isHighlighted = true
            if sticker.alpha == 1 {
                sticker.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.25) {
                    sticker.alpha = 0.5
                }
            }
        } else {
            trashCanView.backgroundColor = .eps.trashCanBackgroundNormalColor
            trashCanImgView.isHighlighted = false
            if sticker.alpha != 1 {
                sticker.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.25) {
                    sticker.alpha = 1
                }
            }
        }
    }
    
    func stickerEndOperation(_ sticker: EPSBaseStickerView, panGes: UIPanGestureRecognizer) {
        setToolView(show: true)
        trashCanView.layer.removeAllAnimations()
        trashCanView.isHidden = true
        
        var endState: EPSBaseStickerState? = sticker.state
        
        let point = panGes.location(in: view)
        if trashCanView.frame.contains(point) {
            sticker.moveToTrashCan()
            endState = nil
        }
        
        editorManager.storeAction(.sticker(oldState: preStickerState, newState: endState))
        preStickerState = nil
        
        stickersContainer.subviews.forEach { view in
            (view as? EPSStickerViewAdditional)?.isGestureEnabled = true
        }
    }
    
    func stickerDidTap(_ sticker: EPSBaseStickerView) {
        stickersContainer.subviews.forEach { view in
            if view !== sticker {
                (view as? EPSStickerViewAdditional)?.resetState()
            }
        }
    }
    
    func sticker(_ textSticker: EPSTextStickerView, editText text: String) {
        showInputTextVC(text, textColor: textSticker.textColor, font: textSticker.font, style: textSticker.style) { text, textColor, font, image, style in
            guard let image = image, !text.isEmpty else {
                textSticker.moveToTrashCan()
                return
            }
            
            textSticker.startTimer()
            guard textSticker.text != text || textSticker.textColor != textColor || textSticker.style != style else {
                return
            }
            textSticker.text = text
            textSticker.textColor = textColor
            textSticker.font = font
            textSticker.style = style
            textSticker.image = image
            let newSize = EPSTextStickerView.calculateSize(image: image)
            textSticker.changeSize(to: newSize)
        }
    }
}

// MARK: unod & redo

extension EPSImageEditorViewController: EPSEditorManagerDelegate {
    func editorManager(_ manager: EPSEditorManager, didUpdateActions actions: [EPSEditorAction], redoActions: [EPSEditorAction]) {
        undoBtn.isEnabled = !actions.isEmpty
        redoBtn.isEnabled = actions.count != redoActions.count
    }
    
    func editorManager(_ manager: EPSEditorManager, undoAction action: EPSEditorAction) {
        switch action {
        case let .draw(path):
            undoDraw(path)
        case let .eraser(paths):
            undoEraser(paths)
        case let .clip(oldStatus, _):
            undoOrRedoClip(oldStatus)
        case let .sticker(oldState, newState):
            undoSticker(oldState, newState)
        case let .mosaic(path):
            undoMosaic(path)
        case let .filter(oldFilter, _):
            undoOrRedoFilter(oldFilter)
        case let .adjust(oldStatus, _):
            undoOrRedoAdjust(oldStatus)
        }
    }
    
    func editorManager(_ manager: EPSEditorManager, redoAction action: EPSEditorAction) {
        switch action {
        case let .draw(path):
            redoDraw(path)
        case let .eraser(paths):
            redoEraser(paths)
        case let .clip(_, newStatus):
            undoOrRedoClip(newStatus)
        case let .sticker(oldState, newState):
            redoSticker(oldState, newState)
        case let .mosaic(path):
            redoMosaic(path)
        case let .filter(_, newFilter):
            undoOrRedoFilter(newFilter)
        case let .adjust(_, newStatus):
            undoOrRedoAdjust(newStatus)
        }
    }
    
    private func undoDraw(_ path: EPSDrawPath) {
        drawPaths.removeLast()
        drawLine()
    }
    
    private func redoDraw(_ path: EPSDrawPath) {
        drawPaths.append(path)
        drawLine()
    }
    
    private func undoEraser(_ paths: [EPSDrawPath]) {
        paths.forEach { $0.willDelete = false }
        drawPaths.append(contentsOf: paths)
        drawPaths = drawPaths.sorted { $0.index < $1.index }
        drawLine()
    }
    
    private func redoEraser(_ paths: [EPSDrawPath]) {
        drawPaths.removeAll { paths.contains($0) }
        drawLine()
    }
    
    private func undoOrRedoClip(_ status: EPSClipStatus) {
        clipImage(status: status)
        preClipStatus = status
    }
    
    private func undoMosaic(_ path: EPSMosaicPath) {
        mosaicPaths.removeLast()
        generateNewMosaicImage()
    }
    
    private func redoMosaic(_ path: EPSMosaicPath) {
        mosaicPaths.append(path)
        generateNewMosaicImage()
    }
    
    private func undoSticker(_ oldState: EPSBaseStickerState?, _ newState: EPSBaseStickerState?) {
        guard let oldState else {
            removeSticker(id: newState?.id)
            return
        }
        
        removeSticker(id: oldState.id)
        if let sticker = EPSBaseStickerView.initWithState(oldState) {
            addSticker(sticker)
        }
    }
    
    private func redoSticker(_ oldState: EPSBaseStickerState?, _ newState: EPSBaseStickerState?) {
        guard let newState else {
            removeSticker(id: oldState?.id)
            return
        }
        
        removeSticker(id: newState.id)
        if let sticker = EPSBaseStickerView.initWithState(newState) {
            addSticker(sticker)
        }
    }
    
    private func undoOrRedoFilter(_ filter: EPSFilter?) {
        guard let filter else { return }
        changeFilter(filter)
        
        let filters = EPSPhotoConfiguration.default().editImageConfiguration.filters
        
        guard let filterCollectionView,
              let index = filters.firstIndex(where: { $0.name == filter.name }) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        filterCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        filterCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        filterCollectionView.reloadData()
    }
    
    private func undoOrRedoAdjust(_ status: EPSAdjustStatus) {
        var adjustTool: EPSImageEditorConfiguration.AdjustTool?
        
        if currentAdjustStatus.brightness != status.brightness {
            adjustTool = .brightness
        } else if currentAdjustStatus.contrast != status.contrast {
            adjustTool = .contrast
        } else if currentAdjustStatus.saturation != status.saturation {
            adjustTool = .saturation
        }
        
        currentAdjustStatus = status
        preAdjustStatus = status
        adjustStatusChanged()
        
        guard let adjustTool else { return }
        
        changeAdjustTool(adjustTool)
        
        guard let adjustCollectionView,
              let index = adjustTools.firstIndex(where: { $0 == adjustTool }) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        adjustCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        adjustCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        adjustCollectionView.reloadData()
    }
}
