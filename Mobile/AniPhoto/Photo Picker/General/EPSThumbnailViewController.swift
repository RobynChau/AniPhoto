//
//  EPSThumbnailViewController.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/19.
//

import UIKit
import Photos

extension EPSThumbnailViewController {
    private enum SlideSelectType {
        case none
        case select
        case cancel
    }
    
    private enum AutoScrollDirection {
        case none
        case top
        case bottom
    }
}

class EPSThumbnailViewController: UIViewController {
    private var albumList: EPSAlbumListModel
    
    private var externalNavView: EPSExternalAlbumListNavView?
    
    private var embedNavView: ZLEmbedAlbumListNavView?
    
    private var embedAlbumListView: EPSEmbedAlbumListView?
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .eps.bottomToolViewBgColor
        return view
    }()
    
    private var bottomBlurView: UIVisualEffectView?
    
    private var limitAuthTipsView: ZLLimitedAuthorityTipsView?
    
    private lazy var previewBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.preview), #selector(previewBtnClick))
        btn.titleLabel?.lineBreakMode = .byCharWrapping
        btn.titleLabel?.numberOfLines = 2
        btn.contentHorizontalAlignment = .left
        btn.isHidden = !EPSPhotoConfiguration.default().showPreviewButtonInAlbum
        return btn
    }()
    
    private lazy var originalBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.originalPhoto), #selector(originalPhotoClick))
        btn.titleLabel?.lineBreakMode = .byCharWrapping
        btn.titleLabel?.numberOfLines = 2
        btn.contentHorizontalAlignment = .left
        btn.setImage(.eps.getImage("zl_btn_original_circle"), for: .normal)
        btn.setImage(.eps.getImage("zl_btn_original_selected"), for: .selected)
        btn.setImage(.eps.getImage("zl_btn_original_selected"), for: [.selected, .highlighted])
        btn.adjustsImageWhenHighlighted = false
        if isRTL() {
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        } else {
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        }
        btn.isHidden = !(EPSPhotoConfiguration.default().allowSelectOriginal && EPSPhotoConfiguration.default().allowSelectImage)
        btn.isSelected = (navigationController as? EPSImageNavController)?.isSelectedOriginal ?? false
        return btn
    }()
    
    private lazy var originalLabel: UILabel = {
        let label = UILabel()
        label.font = .eps.font(ofSize: 12)
        label.textColor = .eps.originalSizeLabelTextColor
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.done), #selector(doneBtnClick), true)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = EPSLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    private lazy var scrollToBottomBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.eps.getImage("zl_arrow_down"), for: .normal)
        btn.addTarget(self, action: #selector(scrollToBottomBtnClick), for: .touchUpInside)
        btn.eps.addShadow(color: .eps.rgba(35, 35, 35), radius: 5, opacity: 1, offset: CGSize(width: 0, height: 3))
        return btn
    }()
    
    /// 所有滑动经过的indexPath
    private lazy var arrSlideIndexPaths: [IndexPath] = []
    
    /// 所有滑动经过的indexPath的初始选择状态
    private lazy var dicOriSelectStatus: [IndexPath: Bool] = [:]
    
    /// 设备旋转前最后一个可视indexPath
    private var lastVisibleIndexPathBeforeRotation: IndexPath?
    
    /// 是否触发了横竖屏切换
    private var isSwitchOrientation = false
    
    /// 是否开始出发滑动选择
    private var beginPanSelect = false
    
    /// 滑动选择 或 取消
    /// 当初始滑动的cell处于未选择状态，则开始选择，反之，则开始取消选择
    private var panSelectType: EPSThumbnailViewController.SlideSelectType = .none
    
    /// 开始滑动的indexPath
    private var beginSlideIndexPath: IndexPath?
    
    /// 最后滑动经过的index，开始的indexPath不计入
    /// 优化拖动手势计算，避免单个cell中冗余计算多次
    private var lastSlideIndex: Int?
    
    /// 拍照后置为true，需要刷新相册列表
    private var hasTakeANewAsset = false
    
    private var slideCalculateQueue = DispatchQueue(label: "com.ZLhotoBrowser.slide")
    
    private var autoScrollTimer: CADisplayLink?
    
    private var lastPanUpdateTime = CACurrentMediaTime()
    
    private let showLimitAuthTipsView: Bool = {
        if #available(iOS 14.0, *),
           PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited,
           EPSPhotoUIConfiguration.default().showEnterSettingTips {
            return true
        } else {
            return false
        }
    }()
    
    private var autoScrollInfo: (direction: AutoScrollDirection, speed: CGFloat) = (.none, 0)
    
    /// 照相按钮+添加图片按钮的数量
    /// the count of addPhotoButton & cameraButton
    private var offset: Int {
        if #available(iOS 14, *) {
            return showAddPhotoCell.eps.intValue + showCameraCell.eps.intValue
        } else {
            return showCameraCell.eps.intValue
        }
    }
    
    private lazy var panGes: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(slideSelectAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = EPSCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .eps.thumbnailBgColor
        view.dataSource = self
        view.delegate = self
        view.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .always
        }
        EPSCameraCell.eps.register(view)
        EPSThumbnailPhotoCell.eps.register(view)
        EPSAddPhotoCell.eps.register(view)
        
        return view
    }()
    
    var arrDataSources: [EPSPhotoModel] = []
    
    var showCameraCell: Bool {
        if EPSPhotoConfiguration.default().allowTakePhotoInLibrary, albumList.isCameraRoll {
            return true
        }
        return false
    }
    
    @available(iOS 14, *)
    var showAddPhotoCell: Bool {
        PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited && EPSPhotoUIConfiguration.default().showAddPhotoButton && albumList.isCameraRoll
    }
    
    private var hiddenStatusBar = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool { hiddenStatusBar }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        EPSPhotoUIConfiguration.default().statusBarStyle
    }
    
    deinit {
        eps_debugPrint("EPSThumbnailViewController deinit")
        cleanTimer()
    }
    
    init(albumList: EPSAlbumListModel) {
        self.albumList = albumList
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        if EPSPhotoConfiguration.default().allowSlideSelect {
            view.addGestureRecognizer(panGes)
        }
        
        loadPhotos()
        
        // Register for the album change notification when the status is limited, because the photoLibraryDidChange method will be repeated multiple times each time the album changes, causing the interface to refresh multiple times. So the album changes are not monitored in other authority.
        if #available(iOS 14.0, *), PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        resetBottomToolBtnStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateScrollToBottomVisibility()
        
        if hiddenStatusBar {
            hiddenStatusBar = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 如果预览界面不显示状态栏，这里隐藏下状态栏，使下拉返回动画期间状态栏不至于闪烁
        if !EPSPhotoUIConfiguration.default().showStatusBarInPreviewInterface {
            hiddenStatusBar = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let navViewNormalH: CGFloat = 44
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        var collectionViewInsetTop: CGFloat = 20
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
            collectionViewInsetTop = navViewNormalH
        } else {
            collectionViewInsetTop += navViewNormalH
        }
        
        let navViewFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: insets.top + navViewNormalH)
        externalNavView?.frame = navViewFrame
        embedNavView?.frame = navViewFrame
        
        embedAlbumListView?.frame = CGRect(x: 0, y: navViewFrame.maxY, width: view.bounds.width, height: view.bounds.height - navViewFrame.maxY)
        
        let showBottomToolBtns = shouldShowBottomToolBar()
        
        let bottomViewH: CGFloat
        if showLimitAuthTipsView, showBottomToolBtns {
            bottomViewH = EPSLayout.bottomToolViewH + ZLLimitedAuthorityTipsView.height
        } else if showLimitAuthTipsView {
            bottomViewH = ZLLimitedAuthorityTipsView.height
        } else if showBottomToolBtns {
            bottomViewH = EPSLayout.bottomToolViewH
        } else {
            bottomViewH = 0
        }
        
        let totalWidth = view.eps.width - insets.left - insets.right
        collectionView.frame = CGRect(x: insets.left, y: 0, width: totalWidth, height: view.frame.height)
        collectionView.contentInset = UIEdgeInsets(top: collectionViewInsetTop, left: 0, bottom: bottomViewH, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: insets.top, left: 0, bottom: bottomViewH, right: 0)

        let scrollToBottomSize = 35.0
        let scrollToBottomX = view.eps.width - insets.right - scrollToBottomSize - 22
        let scrollToBottomY = view.eps.height - insets.bottom - bottomViewH - scrollToBottomSize - 30
        scrollToBottomBtn.frame = CGRect(
            origin: CGPoint(x: scrollToBottomX, y: scrollToBottomY),
            size: CGSize(width: scrollToBottomSize, height: scrollToBottomSize)
        )

        if isSwitchOrientation {
            isSwitchOrientation = false
            
            if let lastVisibleIndexPathBeforeRotation {
                collectionView.scrollToItem(at: lastVisibleIndexPathBeforeRotation, at: .bottom, animated: false)
            }
        }
        
        guard showBottomToolBtns || showLimitAuthTipsView else { return }
        
        let btnH = EPSLayout.bottomToolBtnH
        
        bottomView.frame = CGRect(x: 0, y: view.frame.height - insets.bottom - bottomViewH, width: view.bounds.width, height: bottomViewH + insets.bottom)
        bottomBlurView?.frame = bottomView.bounds
        
        if showLimitAuthTipsView {
            limitAuthTipsView?.frame = CGRect(x: 0, y: 0, width: bottomView.bounds.width, height: ZLLimitedAuthorityTipsView.height)
        }
        
        if showBottomToolBtns {
            let btnMaxWidth = (bottomView.bounds.width - 30) / 3
            
            let btnY = showLimitAuthTipsView ? ZLLimitedAuthorityTipsView.height + EPSLayout.bottomToolBtnY : EPSLayout.bottomToolBtnY
            let previewTitle = localLanguageTextValue(.preview)
            let previewBtnW = previewTitle.eps.boundingRect(font: EPSLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width
            previewBtn.frame = CGRect(x: 15, y: btnY, width: min(btnMaxWidth, previewBtnW), height: btnH)
            
            let originalTitle = localLanguageTextValue(.originalPhoto)
            let originBtnW = originalTitle.eps.boundingRect(
                font: EPSLayout.bottomToolTitleFont,
                limitSize: CGSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: 30
                )
            ).width + (originalBtn.currentImage?.size.width ?? 19) + 12
            let originBtnMaxW = min(btnMaxWidth, originBtnW)
            originalBtn.frame = CGRect(x: (bottomView.eps.width - originBtnMaxW) / 2 - 5, y: btnY, width: originBtnMaxW, height: btnH)
            originalLabel.frame = CGRect(
                x: (bottomView.eps.width - btnMaxWidth) / 2 - 5,
                y: originalBtn.eps.bottom,
                width: btnMaxWidth,
                height: originalLabel.font.lineHeight
            )
            
            refreshDoneBtnFrame()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        lastVisibleIndexPathBeforeRotation = collectionView.indexPathsForVisibleItems
            .max { $0.row < $1.row }
        isSwitchOrientation = true
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = true
        edgesForExtendedLayout = .all
        view.backgroundColor = .eps.thumbnailBgColor
        
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        view.addSubview(scrollToBottomBtn)
        
        if let effect = EPSPhotoUIConfiguration.default().bottomViewBlurEffectOfAlbumList {
            bottomBlurView = UIVisualEffectView(effect: effect)
            bottomView.addSubview(bottomBlurView!)
        }
        
        if showLimitAuthTipsView {
            limitAuthTipsView = ZLLimitedAuthorityTipsView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: ZLLimitedAuthorityTipsView.height))
            bottomView.addSubview(limitAuthTipsView!)
        }
        
        bottomView.addSubview(previewBtn)
        bottomView.addSubview(originalBtn)
        bottomView.addSubview(originalLabel)
        bottomView.addSubview(doneBtn)
        
        setupNavView()
    }
    
    private func setupNavView() {
        if EPSPhotoUIConfiguration.default().style == .embedAlbumList {
            embedNavView = ZLEmbedAlbumListNavView(title: albumList.title)
            
            embedNavView?.selectAlbumBlock = { [weak self] in
                if self?.embedAlbumListView?.isHidden == true {
                    self?.embedAlbumListView?.show(reloadAlbumList: self?.hasTakeANewAsset ?? false)
                    self?.hasTakeANewAsset = false
                } else {
                    self?.embedAlbumListView?.hide()
                }
            }
            
            embedNavView?.cancelBlock = { [weak self] in
                let nav = self?.navigationController as? EPSImageNavController
                nav?.dismiss(animated: true, completion: {
                    nav?.cancelBlock?()
                })
            }
            
            view.addSubview(embedNavView!)
            
            embedAlbumListView = EPSEmbedAlbumListView(selectedAlbum: albumList)
            embedAlbumListView?.isHidden = true
            
            embedAlbumListView?.selectAlbumBlock = { [weak self] album in
                guard self?.albumList != album else {
                    return
                }
                self?.albumList = album
                self?.embedNavView?.title = album.title
                self?.loadPhotos()
                self?.embedNavView?.reset()
            }
            
            embedAlbumListView?.hideBlock = { [weak self] in
                self?.embedNavView?.reset()
            }
            
            view.addSubview(embedAlbumListView!)
        } else if EPSPhotoUIConfiguration.default().style == .externalAlbumList {
            externalNavView = EPSExternalAlbumListNavView(title: albumList.title)
            
            externalNavView?.backBlock = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            
            externalNavView?.cancelBlock = { [weak self] in
                let nav = self?.navigationController as? EPSImageNavController
                nav?.cancelBlock?()
                nav?.dismiss(animated: true, completion: nil)
            }
            
            view.addSubview(externalNavView!)
        }
    }
    
    private func createBtn(_ title: String, _ action: Selector, _ isDone: Bool = false) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = EPSLayout.bottomToolTitleFont
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(
            isDone ? .eps.bottomToolViewDoneBtnNormalTitleColor : .eps.bottomToolViewBtnNormalTitleColor,
            for: .normal
        )
        btn.setTitleColor(
            isDone ? .eps.bottomToolViewDoneBtnDisableTitleColor : .eps.bottomToolViewBtnDisableTitleColor,
            for: .disabled
        )
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    private func loadPhotos() {
        guard let nav = navigationController as? EPSImageNavController else {
            return
        }
        
        let hud = EPSProgressHUD.show(in: view)
        
        DispatchQueue.global().async {
            var datas: [EPSPhotoModel] = []
            
            if self.albumList.models.isEmpty {
                self.albumList.refetchPhotos()
                
                datas.append(contentsOf: self.albumList.models)
                markSelected(source: &datas, selected: &nav.arrSelectedModels)
            } else {
                datas.append(contentsOf: self.albumList.models)
                markSelected(source: &datas, selected: &nav.arrSelectedModels)
            }
            
            EPSMainAsync {
                hud.hide()
                
                self.arrDataSources.removeAll()
                self.arrDataSources.append(contentsOf: datas)
                self.collectionView.reloadData()
                self.scrollToTopOrBottom()
                
                self.scrollToBottomBtn.alpha = 0
                var transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                if !EPSPhotoUIConfiguration.default().sortAscending {
                    transform = transform.rotated(by: .pi)
                }
                self.scrollToBottomBtn.transform = transform
            }
        }
    }
    
    private func shouldShowBottomToolBar() -> Bool {
        let config = EPSPhotoConfiguration.default()
        let condition1 = config.editAfterSelectThumbnailImage &&
            config.maxSelectCount == 1 &&
            (config.allowEditImage || config.allowEditVideo)
        let condition2 = config.allowPreviewPhotos && config.maxSelectCount == 1 && !config.showSelectBtnWhenSingleSelect
        let condition3 = !config.allowPreviewPhotos && config.maxSelectCount == 1
        if condition1 || condition2 || condition3 {
            return false
        }
        return true
    }
    
    private func updateScrollToBottomVisibility() {
        let config = EPSPhotoUIConfiguration.default()
        guard config.showScrollToBottomBtn else {
            scrollToBottomBtn.isHidden = true
            return
        }
        
        let flag = collectionView.eps.height / 2
        var transform: CGAffineTransform = .identity
        
        let shouldShow: Bool
        if config.sortAscending {
            let maxOffsetY = collectionView.contentSize.height + collectionView.eps.contentInset.bottom - collectionView.eps.height
            let showBtnOffsetY = maxOffsetY - flag
            shouldShow = collectionView.contentOffset.y <= showBtnOffsetY
        } else {
            shouldShow = collectionView.eps.contentInset.top + collectionView.contentOffset.y >= flag
            transform = transform.rotated(by: .pi)
        }
        
        if (shouldShow && scrollToBottomBtn.alpha == 1) ||
            (!shouldShow && scrollToBottomBtn.alpha == 0) {
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState]) {
            self.scrollToBottomBtn.alpha = shouldShow ? 1 : 0
            self.scrollToBottomBtn.transform = shouldShow ? transform : transform.scaledBy(x: 0.5, y: 0.5)
        }
    }
    
    // MARK: btn actions
    
    @objc private func previewBtnClick() {
        guard let nav = navigationController as? EPSImageNavController else {
            epsLoggerInDebug("Navigation controller is null")
            return
        }
        let vc = EPSPhotoPreviewController(photos: nav.arrSelectedModels, index: 0)
        show(vc, sender: nil)
    }
    
    @objc private func originalPhotoClick() {
        originalBtn.isSelected.toggle()
        refreshOriginalLabelText()
        (navigationController as? EPSImageNavController)?.isSelectedOriginal = originalBtn.isSelected
    }
    
    @objc private func doneBtnClick() {
        let nav = navigationController as? EPSImageNavController
        if let block = EPSPhotoConfiguration.default().operateBeforeDoneAction {
            block(self) { [weak nav] in
                nav?.selectImageBlock?()
            }
        } else {
            nav?.selectImageBlock?()
        }
    }
    
    @objc private func scrollToBottomBtnClick() {
        if EPSPhotoUIConfiguration.default().sortAscending {
            collectionView.eps.scrollToBottom()
        } else {
            collectionView.eps.scrollToTop()
        }
    }
    
    @objc private func slideSelectAction(_ pan: UIPanGestureRecognizer) {
        if pan.state == .ended || pan.state == .cancelled {
            stopAutoScroll()
            beginPanSelect = false
            panSelectType = .none
            arrSlideIndexPaths.removeAll()
            dicOriSelectStatus.removeAll()
            resetBottomToolBtnStatus()
            return
        }
        
        let point = pan.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point),
              let nav = navigationController as? EPSImageNavController else {
            return
        }
        
        let config = EPSPhotoConfiguration.default()
        let cell = collectionView.cellForItem(at: indexPath) as? EPSThumbnailPhotoCell
        let asc = EPSPhotoUIConfiguration.default().sortAscending
        
        if pan.state == .began {
            beginPanSelect = cell != nil
            
            if beginPanSelect {
                let index = asc ? indexPath.row : indexPath.row - offset
                
                let m = arrDataSources[index]
                panSelectType = m.isSelected ? .cancel : .select
                beginSlideIndexPath = indexPath
                
                if !m.isSelected {
                    if nav.arrSelectedModels.count >= config.maxSelectCount {
                        panSelectType = .none
                        return
                    }
                    
                    if !(cell?.enableSelect ?? true) || !canAddModel(m, currentSelectCount: nav.arrSelectedModels.count, sender: self) {
                        panSelectType = .none
                        return
                    }
                    
                    if shouldDirectEdit(m) {
                        panSelectType = .none
                        return
                    } else {
                        m.isSelected = true
                        nav.arrSelectedModels.append(m)
                        config.didSelectAsset?(m.asset)
                    }
                } else if m.isSelected {
                    m.isSelected = false
                    nav.arrSelectedModels.removeAll { $0 == m }
                    config.didDeselectAsset?(m.asset)
                }
                
                cell?.btnSelect.isSelected = m.isSelected
                refreshCellIndexAndMaskView()
                resetBottomToolBtnStatus()
                lastSlideIndex = indexPath.row
            }
        } else if pan.state == .changed {
            if !beginPanSelect || indexPath.row == lastSlideIndex || panSelectType == .none || cell == nil {
                return
            }
            
            autoScrollWhenSlideSelect(pan)
            
            guard let beginIndexPath = beginSlideIndexPath else {
                return
            }
            lastPanUpdateTime = CACurrentMediaTime()
            
            let visiblePaths = collectionView.indexPathsForVisibleItems
            slideCalculateQueue.async {
                self.lastSlideIndex = indexPath.row
                let minIndex = min(indexPath.row, beginIndexPath.row)
                let maxIndex = max(indexPath.row, beginIndexPath.row)
                let minIsBegin = minIndex == beginIndexPath.row
                
                var i = beginIndexPath.row
                while minIsBegin ? i <= maxIndex : i >= minIndex {
                    if i != beginIndexPath.row {
                        let p = IndexPath(row: i, section: 0)
                        if !self.arrSlideIndexPaths.contains(p) {
                            self.arrSlideIndexPaths.append(p)
                            let index = asc ? i : i - self.offset
                            let m = self.arrDataSources[index]
                            self.dicOriSelectStatus[p] = m.isSelected
                        }
                    }
                    i += (minIsBegin ? 1 : -1)
                }
                
                var selectedArrHasChange = false
                
                for path in self.arrSlideIndexPaths {
                    if !visiblePaths.contains(path) {
                        continue
                    }
                    let index = asc ? path.row : path.row - self.offset
                    // 是否在最初和现在的间隔区间内
                    let inSection = path.row >= minIndex && path.row <= maxIndex
                    let m = self.arrDataSources[index]
                    
                    if inSection {
                        if self.panSelectType == .select {
                            if !m.isSelected,
                               canAddModel(m, currentSelectCount: nav.arrSelectedModels.count, sender: self, showAlert: false) {
                                m.isSelected = true
                            }
                        } else if self.panSelectType == .cancel {
                            m.isSelected = false
                        }
                    } else {
                        // 未在区间内的model还原为初始选择状态
                        m.isSelected = self.dicOriSelectStatus[path] ?? false
                    }
                    
                    if !m.isSelected {
                        if let index = nav.arrSelectedModels.firstIndex(where: { $0 == m }) {
                            nav.arrSelectedModels.remove(at: index)
                            selectedArrHasChange = true
                            
                            EPSMainAsync {
                                config.didDeselectAsset?(m.asset)
                            }
                        }
                    } else {
                        if !nav.arrSelectedModels.contains(where: { $0 == m }) {
                            nav.arrSelectedModels.append(m)
                            selectedArrHasChange = true
                            
                            EPSMainAsync {
                                config.didSelectAsset?(m.asset)
                            }
                        }
                    }
                    
                    EPSMainAsync {
                        let c = self.collectionView.cellForItem(at: path) as? EPSThumbnailPhotoCell
                        c?.btnSelect.isSelected = m.isSelected
                    }
                }
                
                if selectedArrHasChange {
                    EPSMainAsync {
                        self.refreshCellIndexAndMaskView()
                        self.resetBottomToolBtnStatus()
                    }
                }
            }
        }
    }
    
    private func autoScrollWhenSlideSelect(_ pan: UIPanGestureRecognizer) {
        guard EPSPhotoConfiguration.default().autoScrollWhenSlideSelectIsActive else {
            return
        }
        let arrSel = (navigationController as? EPSImageNavController)?.arrSelectedModels ?? []
        guard arrSel.count < EPSPhotoConfiguration.default().maxSelectCount else {
            // Stop auto scroll when reach the max select count.
            stopAutoScroll()
            return
        }
        
        let top = ((embedNavView?.frame.height ?? externalNavView?.frame.height) ?? 44) + 30
        let bottom = bottomView.frame.minY - 30
        
        let point = pan.location(in: view)
        
        var diff: CGFloat = 0
        var direction: AutoScrollDirection = .none
        if point.y < top {
            diff = top - point.y
            direction = .top
        } else if point.y > bottom {
            diff = point.y - bottom
            direction = .bottom
        } else {
            stopAutoScroll()
            return
        }
        
        guard diff > 0 else { return }
        
        let s = min(diff, 60) / 60 * EPSPhotoConfiguration.default().autoScrollMaxSpeed
        
        autoScrollInfo = (direction, s)
        
        if autoScrollTimer == nil {
            cleanTimer()
            autoScrollTimer = CADisplayLink(target: EPSWeakProxy(target: self), selector: #selector(autoScrollAction))
            autoScrollTimer?.add(to: RunLoop.current, forMode: .common)
        }
    }
    
    private func cleanTimer() {
        autoScrollTimer?.remove(from: RunLoop.current, forMode: .common)
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    private func stopAutoScroll() {
        autoScrollInfo = (.none, 0)
        cleanTimer()
    }
    
    @objc private func autoScrollAction() {
        guard autoScrollInfo.direction != .none, panGes.state != .possible else {
            stopAutoScroll()
            return
        }
        let duration = CGFloat(autoScrollTimer?.duration ?? 1 / 60)
        if CACurrentMediaTime() - lastPanUpdateTime > 0.2 {
            // Finger may be not moved in slide selection mode
            slideSelectAction(panGes)
        }
        let distance = autoScrollInfo.speed * duration
        let offset = collectionView.contentOffset
        let inset = collectionView.contentInset
        if autoScrollInfo.direction == .top, offset.y + inset.top > distance {
            collectionView.contentOffset = CGPoint(x: 0, y: offset.y - distance)
        } else if autoScrollInfo.direction == .bottom, offset.y + collectionView.bounds.height + distance - inset.bottom < collectionView.contentSize.height {
            collectionView.contentOffset = CGPoint(x: 0, y: offset.y + distance)
        }
    }
    
    private func resetBottomToolBtnStatus() {
        guard shouldShowBottomToolBar() else { return }
        guard let nav = navigationController as? EPSImageNavController else {
            epsLoggerInDebug("Navigation controller is null")
            return
        }
        var doneTitle = localLanguageTextValue(.done)
        if EPSPhotoConfiguration.default().showSelectCountOnDoneBtn,
           !nav.arrSelectedModels.isEmpty {
            doneTitle += "(" + String(nav.arrSelectedModels.count) + ")"
        }
        if !nav.arrSelectedModels.isEmpty {
            previewBtn.isEnabled = true
            doneBtn.isEnabled = true
            doneBtn.setTitle(doneTitle, for: .normal)
            doneBtn.backgroundColor = .eps.bottomToolViewBtnNormalBgColor
        } else {
            previewBtn.isEnabled = false
            doneBtn.isEnabled = false
            doneBtn.setTitle(doneTitle, for: .normal)
            doneBtn.backgroundColor = .eps.bottomToolViewBtnDisableBgColor
        }
        originalBtn.isSelected = nav.isSelectedOriginal
        refreshOriginalLabelText()
        refreshDoneBtnFrame()
    }
    
    private func refreshOriginalLabelText() {
        guard EPSPhotoConfiguration.default().showOriginalSizeWhenSelectOriginal else {
            return
        }
        
        guard originalBtn.isSelected else {
            originalLabel.isHidden = true
            return
        }
        
        let selectModels = (navigationController as? EPSImageNavController)?.arrSelectedModels ?? []
        if selectModels.isEmpty {
            originalLabel.isHidden = true
        } else {
            originalLabel.isHidden = false
            let totalSize = selectModels.reduce(into: 0) { $0 += ($1.dataSize ?? 0) * 1024 }
            let str = ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .binary).replacingOccurrences(of: " ", with: "")
            originalLabel.text = localLanguageTextValue(.originalTotalSize) + " \(str)"
        }
    }
    
    private func refreshDoneBtnFrame() {
        let doneBtnW = (doneBtn.currentTitle ?? "")
            .eps.boundingRect(
                font: EPSLayout.bottomToolTitleFont,
                limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)
            ).width + 20
        
        let btnY = showLimitAuthTipsView ? ZLLimitedAuthorityTipsView.height + EPSLayout.bottomToolBtnY : EPSLayout.bottomToolBtnY
        doneBtn.frame = CGRect(x: bottomView.bounds.width - doneBtnW - 15, y: btnY, width: doneBtnW, height: EPSLayout.bottomToolBtnH)
    }
    
    private func scrollToTopOrBottom() {
        guard !arrDataSources.isEmpty else {
            return
        }
        
        if EPSPhotoUIConfiguration.default().sortAscending {
            let index = arrDataSources.count - 1 + offset
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: false)
        } else {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: false)
        }
    }
    
    private func showCamera() {
        let config = EPSPhotoConfiguration.default()
        if config.useCustomCamera {
            let camera = EPSCustomCamera()
            camera.takeDoneBlock = { [weak self] image, videoUrl in
                self?.save(image: image, videoUrl: videoUrl)
            }
            showDetailViewController(camera, sender: nil)
        } else {
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                showAlertView(localLanguageTextValue(.cameraUnavailable), self)
            } else if EPSPhotoManager.hasCameraAuthority() {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.videoQuality = .typeHigh
                picker.sourceType = .camera
                picker.cameraDevice = config.cameraConfiguration.devicePosition.cameraDevice
                if config.cameraConfiguration.showFlashSwitch {
                    picker.cameraFlashMode = .auto
                } else {
                    picker.cameraFlashMode = .off
                }
                var mediaTypes: [String] = []
                if config.cameraConfiguration.allowTakePhoto {
                    mediaTypes.append("public.image")
                }
                if config.cameraConfiguration.allowRecordVideo {
                    mediaTypes.append("public.movie")
                }
                picker.mediaTypes = mediaTypes
                picker.videoMaximumDuration = TimeInterval(config.cameraConfiguration.maxRecordDuration)
                showDetailViewController(picker, sender: nil)
            } else {
                showAlertView(String(format: localLanguageTextValue(.noCameraAuthority), getAppName()), self)
            }
        }
    }
    
    private func save(image: UIImage?, videoUrl: URL?) {
        if let image {
            let hud = EPSProgressHUD.show(toast: .processing)
            EPSPhotoManager.saveImageToAlbum(image: image) { [weak self] suc, asset in
                if suc, let asset {
                    let model = EPSPhotoModel(asset: asset)
                    self?.handleDataArray(newModel: model)
                } else {
                    showAlertView(localLanguageTextValue(.saveImageError), self)
                }
                hud.hide()
            }
        } else if let videoUrl {
            let hud = EPSProgressHUD.show(toast: .processing)
            EPSPhotoManager.saveVideoToAlbum(url: videoUrl) { [weak self] suc, asset in
                if suc, let asset {
                    let model = EPSPhotoModel(asset: asset)
                    self?.handleDataArray(newModel: model)
                } else {
                    showAlertView(localLanguageTextValue(.saveVideoError), self)
                }
                hud.hide()
            }
        }
    }
    
    private func handleDataArray(newModel: EPSPhotoModel) {
        hasTakeANewAsset = true
        albumList.refreshResult()
        
        let nav = navigationController as? EPSImageNavController
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        var insertIndex = 0
        
        if uiConfig.sortAscending {
            insertIndex = arrDataSources.count
            arrDataSources.append(newModel)
        } else {
            // 保存拍照的照片或者视频，说明肯定有camera cell
            insertIndex = offset
            arrDataSources.insert(newModel, at: 0)
        }
        
        var canSelect = true
        // If mixed selection is not allowed, and the newModel type is video, it will not be selected.
        if !config.allowMixSelect, newModel.type == .video {
            canSelect = false
        }
        // 单选模式，且不显示选择按钮时，不允许选择
        if config.maxSelectCount == 1, !config.showSelectBtnWhenSingleSelect {
            canSelect = false
        }
        if canSelect, canAddModel(newModel, currentSelectCount: nav?.arrSelectedModels.count ?? 0, sender: self, showAlert: false) {
            if !shouldDirectEdit(newModel) {
                newModel.isSelected = true
                nav?.arrSelectedModels.append(newModel)
                config.didSelectAsset?(newModel.asset)
                
                if config.callbackDirectlyAfterTakingPhoto {
                    doneBtnClick()
                    return
                }
            }
        }
        
        let insertIndexPath = IndexPath(row: insertIndex, section: 0)
        collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: [insertIndexPath])
        } completion: { _ in
            self.collectionView.scrollToItem(at: insertIndexPath, at: .centeredVertically, animated: true)
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
        
        resetBottomToolBtnStatus()
    }
    
    private func showEditImageVC(model: EPSPhotoModel) {
        guard let nav = navigationController as? EPSImageNavController else {
            epsLoggerInDebug("Navigation controller is null")
            return
        }
        
        var requestAssetID: PHImageRequestID?
        
        let hud = EPSProgressHUD.show(timeout: EPSPhotoUIConfiguration.default().timeout)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self)
            if let requestAssetID = requestAssetID {
                PHImageManager.default().cancelImageRequest(requestAssetID)
            }
        }
        
        requestAssetID = EPSPhotoManager.fetchImage(for: model.asset, size: model.previewSize) { [weak self, weak nav] image, isDegraded in
            guard !isDegraded else {
                return
            }
            
            if let image = image {
                EPSImageEditorViewController.showEditImageVC(parentVC: self, image: image, editModel: model.editImageModel) { [weak nav] ei, editImageModel in
                    model.isSelected = true
                    model.editImage = ei
                    model.editImageModel = editImageModel
                    nav?.arrSelectedModels.append(model)
                    EPSPhotoConfiguration.default().didSelectAsset?(model.asset)
                    self?.doneBtnClick()
                }
            } else {
                showAlertView(localLanguageTextValue(.imageLoadFailed), self)
            }
            
            hud.hide()
        }
    }
    
    private func showEditVideoVC(model: EPSPhotoModel) {
        let nav = navigationController as? EPSImageNavController
        let config = EPSPhotoConfiguration.default()
        
        var requestAssetID: PHImageRequestID?
        let hud = EPSProgressHUD.show(timeout: EPSPhotoUIConfiguration.default().timeout)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self)
            if let requestAssetID = requestAssetID {
                PHImageManager.default().cancelImageRequest(requestAssetID)
            }
        }
        
        func inner_showEditVideoVC(_ avAsset: AVAsset) {
            let vc = EPSVideoEditorViewController(avAsset: avAsset)
            vc.editFinishBlock = { [weak self, weak nav] url in
                if let url = url {
                    EPSPhotoManager.saveVideoToAlbum(url: url) { [weak self, weak nav] suc, asset in
                        if suc, let asset = asset {
                            let m = EPSPhotoModel(asset: asset)
                            m.isSelected = true
                            nav?.arrSelectedModels.append(m)
                            config.didSelectAsset?(m.asset)
                            
                            self?.doneBtnClick()
                        } else {
                            showAlertView(localLanguageTextValue(.saveVideoError), self)
                        }
                    }
                } else {
                    model.isSelected = true
                    nav?.arrSelectedModels.append(model)
                    config.didSelectAsset?(model.asset)
                    
                    self?.doneBtnClick()
                }
            }
            vc.modalPresentationStyle = .fullScreen
            showDetailViewController(vc, sender: nil)
        }
        
        // 提前fetch一下 avasset
        requestAssetID = EPSPhotoManager.fetchAVAsset(forVideo: model.asset) { [weak self] avAsset, _ in
            hud.hide()
            if let avAsset = avAsset {
                inner_showEditVideoVC(avAsset)
            } else {
                showAlertView(localLanguageTextValue(.timeout), self)
            }
        }
    }
    
    /// 预判界面执行pop动画时，该界面需要执行的内容
    func endPopTransition() {
        hiddenStatusBar = false
        if deviceIsiPad() {
            view.setNeedsLayout()
        }
    }
}

// MARK: Gesture delegate

extension EPSThumbnailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let config = EPSPhotoConfiguration.default()
        if (config.maxSelectCount == 1 && !config.showSelectBtnWhenSingleSelect) || embedAlbumListView?.isHidden == false {
            return false
        }
        
        let point = gestureRecognizer.location(in: view)
        let navFrame = (embedNavView ?? externalNavView)?.frame ?? .zero
        if navFrame.contains(point) ||
            bottomView.frame.contains(point) {
            return false
        }
        
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)
        if collectionView.indexPathForItem(at: pointInCollectionView) == nil {
            return false
        }
        
        return true
    }
}

// MARK: CollectionView Delegate & DataSource

extension EPSThumbnailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return EPSPhotoUIConfiguration.default().minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return EPSPhotoUIConfiguration.default().minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let uiConfig = EPSPhotoUIConfiguration.default()
        var columnCount: Int
        
        if let columnCountBlock = uiConfig.columnCountBlock {
            columnCount = columnCountBlock(collectionView.eps.width)
        } else {
            let defaultCount = uiConfig.columnCount
            columnCount = deviceIsiPad() ? (defaultCount + 2) : defaultCount
            if UIApplication.shared.statusBarOrientation.isLandscape {
                columnCount += 2
            }
        }
        
        let totalW = collectionView.bounds.width - CGFloat(columnCount - 1) * uiConfig.minimumInteritemSpacing
        let singleW = totalW / CGFloat(columnCount)
        return CGSize(width: singleW, height: singleW)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrDataSources.count + offset
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        let nav = navigationController as? EPSImageNavController
        
        if showCameraCell, (uiConfig.sortAscending && indexPath.row == arrDataSources.count) || (!uiConfig.sortAscending && indexPath.row == 0) {
            // camera cell
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSCameraCell.eps.identifier, for: indexPath) as! EPSCameraCell
            
            if uiConfig.showCaptureImageOnTakePhotoBtn {
                cell.startCapture()
            }
            
            cell.isEnable = (nav?.arrSelectedModels.count ?? 0) < config.maxSelectCount
            
            return cell
        }
        
        if #available(iOS 14, *) {
            if self.showAddPhotoCell, (uiConfig.sortAscending && indexPath.row == self.arrDataSources.count - 1 + self.offset) || (!uiConfig.sortAscending && indexPath.row == self.offset - 1) {
                return collectionView.dequeueReusableCell(withReuseIdentifier: EPSAddPhotoCell.eps.identifier, for: indexPath)
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSThumbnailPhotoCell.eps.identifier, for: indexPath) as! EPSThumbnailPhotoCell
        
        let model: EPSPhotoModel
        
        if !uiConfig.sortAscending {
            model = arrDataSources[indexPath.row - offset]
        } else {
            model = arrDataSources[indexPath.row]
        }
        
        cell.selectedBlock = { [weak self, weak nav] block in
            if !model.isSelected {
                let currentSelectCount = nav?.arrSelectedModels.count ?? 0
                guard canAddModel(model, currentSelectCount: currentSelectCount, sender: self) else {
                    return
                }
                
                downloadAssetIfNeed(model: model, sender: self) {
                    if self?.shouldDirectEdit(model) == false {
                        model.isSelected = true
                        nav?.arrSelectedModels.append(model)
                        block(true)
                        
                        config.didSelectAsset?(model.asset)
                        self?.refreshCellIndexAndMaskView()
                        
                        if config.maxSelectCount == 1, !config.allowPreviewPhotos {
                            self?.doneBtnClick()
                        }
                        
                        self?.resetBottomToolBtnStatus()
                    }
                }
            } else {
                model.isSelected = false
                nav?.arrSelectedModels.removeAll { $0 == model }
                block(false)
                
                config.didDeselectAsset?(model.asset)
                self?.refreshCellIndexAndMaskView()
                
                self?.resetBottomToolBtnStatus()
            }
        }
        
        if config.showSelectedIndex,
           let index = nav?.arrSelectedModels.firstIndex(where: { $0 == model }) {
            setCellIndex(cell, showIndexLabel: true, index: index + config.initialIndex)
        } else {
            cell.indexLabel.isHidden = true
        }
        
        setCellMaskView(cell, isSelected: model.isSelected, model: model)
        
        cell.model = model
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? EPSThumbnailPhotoCell else {
            return
        }
        var index = indexPath.row
        if !EPSPhotoUIConfiguration.default().sortAscending {
            index -= offset
        }
        
        guard arrDataSources.indices ~= index else {
            return
        }
        
        let model = arrDataSources[index]
        setCellMaskView(c, isSelected: model.isSelected, model: model)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? EPSCameraCell {
            if cell.isEnable {
                showCamera()
            }
            return
        }
        
        if #available(iOS 14, *) {
            if cell is EPSAddPhotoCell {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
                return
            }
        }
        
        guard let cell = cell as? EPSThumbnailPhotoCell else {
            return
        }
        
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        
        if !config.allowPreviewPhotos {
            cell.btnSelectClick()
            return
        }
        
        // 不允许选择，且上面有蒙层时，不准点击
        if !cell.enableSelect, uiConfig.showInvalidMask {
            return
        }
        
        var index = indexPath.row
        if !uiConfig.sortAscending {
            index -= offset
        }
        
        guard arrDataSources.indices ~= index else {
            return
        }
        
        let m = arrDataSources[index]
        if shouldDirectEdit(m) {
            return
        }
        
        let vc = EPSPhotoPreviewController(photos: arrDataSources, index: index)
        vc.backBlock = { [weak self] in
            guard let `self` = self, self.hiddenStatusBar else { return }
            self.hiddenStatusBar = false
        }
        show(vc, sender: nil)
    }
    
    private func shouldDirectEdit(_ model: EPSPhotoModel) -> Bool {
        let config = EPSPhotoConfiguration.default()
        
        let canEditImage = config.editAfterSelectThumbnailImage &&
            config.allowEditImage &&
            config.maxSelectCount == 1 &&
            model.type.rawValue < EPSPhotoModel.MediaType.video.rawValue
        
        let canEditVideo = (config.editAfterSelectThumbnailImage &&
            config.allowEditVideo &&
            model.type == .video &&
            config.maxSelectCount == 1) ||
            (config.allowEditVideo &&
                model.type == .video &&
                !config.allowMixSelect &&
                config.cropVideoAfterSelectThumbnail)
        
        // 当前未选择图片 或已经选择了一张并且点击的是已选择的图片
        let nav = navigationController as? EPSImageNavController
        let arrSelectedModels = nav?.arrSelectedModels ?? []
        let flag = arrSelectedModels.isEmpty || (arrSelectedModels.count == 1 && arrSelectedModels.first?.ident == model.ident)
        
        if canEditImage, flag {
            showEditImageVC(model: model)
        } else if canEditVideo, flag {
            showEditVideoVC(model: model)
        }
        
        return flag && (canEditImage || canEditVideo)
    }
    
    private func setCellIndex(_ cell: EPSThumbnailPhotoCell?, showIndexLabel: Bool, index: Int) {
        guard EPSPhotoConfiguration.default().showSelectedIndex else {
            return
        }
        cell?.index = index
        cell?.indexLabel.isHidden = !showIndexLabel
    }
    
    private func refreshCellIndexAndMaskView() {
        refreshCameraCellStatus()
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        let showIndex = config.showSelectedIndex
        let showMask = uiConfig.showSelectedMask || uiConfig.showInvalidMask
        
        guard showIndex || showMask else {
            return
        }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        visibleIndexPaths.forEach { indexPath in
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? EPSThumbnailPhotoCell else {
                return
            }
            var row = indexPath.row
            if !uiConfig.sortAscending {
                row -= self.offset
            }
            let m = self.arrDataSources[row]
            
            let arrSel = (self.navigationController as? EPSImageNavController)?.arrSelectedModels ?? []
            var show = false
            var idx = 0
            var isSelected = false
            for (index, selM) in arrSel.enumerated() {
                if m == selM {
                    show = true
                    idx = index + config.initialIndex
                    isSelected = true
                    break
                }
            }
            if showIndex {
                self.setCellIndex(cell, showIndexLabel: show, index: idx)
            }
            if showMask {
                self.setCellMaskView(cell, isSelected: isSelected, model: m)
            }
        }
    }
    
    private func setCellMaskView(_ cell: EPSThumbnailPhotoCell, isSelected: Bool, model: EPSPhotoModel) {
        cell.coverView.isHidden = true
        cell.enableSelect = true
        let arrSel = (navigationController as? EPSImageNavController)?.arrSelectedModels ?? []
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        
        if isSelected {
            cell.coverView.backgroundColor = .eps.selectedMaskColor
            cell.coverView.isHidden = !uiConfig.showSelectedMask
            if uiConfig.showSelectedBorder {
                cell.layer.borderWidth = 4
            }
        } else {
            let selCount = arrSel.count
            if selCount < config.maxSelectCount {
                if config.allowMixSelect {
                    let videoCount = arrSel.filter { $0.type == .video }.count
                    if videoCount >= config.maxVideoSelectCount, model.type == .video {
                        cell.coverView.backgroundColor = .eps.invalidMaskColor
                        cell.coverView.isHidden = !uiConfig.showInvalidMask
                        cell.enableSelect = false
                    } else if (config.maxSelectCount - selCount) <= (config.minVideoSelectCount - videoCount), model.type != .video {
                        cell.coverView.backgroundColor = .eps.invalidMaskColor
                        cell.coverView.isHidden = !uiConfig.showInvalidMask
                        cell.enableSelect = false
                    }
                } else if selCount > 0 {
                    cell.coverView.backgroundColor = .eps.invalidMaskColor
                    cell.coverView.isHidden = (!uiConfig.showInvalidMask || model.type != .video)
                    cell.enableSelect = model.type != .video
                }
            } else if selCount >= config.maxSelectCount {
                cell.coverView.backgroundColor = .eps.invalidMaskColor
                cell.coverView.isHidden = !uiConfig.showInvalidMask
                cell.enableSelect = false
            }
            if uiConfig.showSelectedBorder {
                cell.layer.borderWidth = 0
            }
        }
    }
    
    private func refreshCameraCellStatus() {
        let count = (navigationController as? EPSImageNavController)?.arrSelectedModels.count ?? 0
        
        for cell in collectionView.visibleCells {
            if let cell = cell as? EPSCameraCell {
                cell.isEnable = count < EPSPhotoConfiguration.default().maxSelectCount
                break
            }
        }
    }
}

// MARK: ScrollView Delegate

extension EPSThumbnailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateScrollToBottomVisibility()
    }
}

// MARK: Image picker delegate

extension EPSThumbnailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            let image = info[.originalImage] as? UIImage
            let url = info[.mediaURL] as? URL
            self.save(image: image, videoUrl: url)
        }
    }
}

// MARK: Photo library change observer

extension EPSThumbnailViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: albumList.result) else {
            return
        }
        
        EPSMainAsync {
            guard let nav = self.navigationController as? EPSImageNavController else {
                epsLoggerInDebug("Navigation controller is null")
                return
            }
            // 变化后再次显示相册列表需要刷新
            self.hasTakeANewAsset = true
            self.albumList.result = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                for sm in nav.arrSelectedModels {
                    let isDelete = changeInstance.changeDetails(for: sm.asset)?.objectWasDeleted ?? false
                    if isDelete {
                        nav.arrSelectedModels.removeAll { $0 == sm }
                    }
                }
                if !changes.removedObjects.isEmpty || !changes.insertedObjects.isEmpty {
                    self.albumList.models.removeAll()
                }
                
                self.loadPhotos()
            } else {
                for sm in nav.arrSelectedModels {
                    let isDelete = changeInstance.changeDetails(for: sm.asset)?.objectWasDeleted ?? false
                    if isDelete {
                        nav.arrSelectedModels.removeAll { $0 == sm }
                    }
                }
                self.albumList.models.removeAll()
                self.loadPhotos()
            }
            self.resetBottomToolBtnStatus()
        }
    }
}

// MARK: embed album list nav view

class ZLEmbedAlbumListNavView: UIView {
    private static let titleViewH: CGFloat = 32
    
    private static let arrowH: CGFloat = 20
    
    private var navBlurView: UIVisualEffectView?
    
    private lazy var titleBgControl: UIControl = {
        let control = UIControl()
        control.backgroundColor = .eps.navEmbedTitleViewBgColor
        control.layer.cornerRadius = ZLEmbedAlbumListNavView.titleViewH / 2
        control.layer.masksToBounds = true
        control.addTarget(self, action: #selector(titleBgControlClick), for: .touchUpInside)
        return control
    }()
    
    private lazy var albumTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .eps.navTitleColor
        label.font = EPSLayout.navTitleFont
        label.text = title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var arrow: UIImageView = {
        let view = UIImageView(image: .eps.getImage("zl_downArrow"))
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        if EPSPhotoUIConfiguration.default().navCancelButtonStyle == .text {
            btn.titleLabel?.font = EPSLayout.navTitleFont
            btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
            btn.setTitleColor(.eps.navTitleColor, for: .normal)
        } else {
            btn.setImage(.eps.getImage("zl_navClose"), for: .normal)
        }
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    var title: String {
        didSet {
            albumTitleLabel.text = title
            refreshTitleViewFrame()
        }
    }
    
    var selectAlbumBlock: (() -> Void)?
    
    var cancelBlock: (() -> Void)?
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = safeAreaInsets
        }
        
        refreshTitleViewFrame()
        if EPSPhotoUIConfiguration.default().navCancelButtonStyle == .text {
            let cancelBtnW = localLanguageTextValue(.cancel).eps.boundingRect(font: EPSLayout.navTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)).width
            cancelBtn.frame = CGRect(x: insets.left + 20, y: insets.top, width: cancelBtnW, height: 44)
        } else {
            cancelBtn.frame = CGRect(x: insets.left + 10, y: insets.top, width: 44, height: 44)
        }
    }
    
    private func refreshTitleViewFrame() {
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = safeAreaInsets
        }
        
        navBlurView?.frame = bounds
        
        let albumTitleW = min(
            bounds.width / 2,
            title.eps.boundingRect(
                font: EPSLayout.navTitleFont,
                limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)
            ).width
        )
        let titleBgControlW = albumTitleW + ZLEmbedAlbumListNavView.arrowH + 20
        
        UIView.animate(withDuration: 0.25) {
            self.titleBgControl.frame = CGRect(
                x: (self.frame.width - titleBgControlW) / 2,
                y: insets.top + (44 - ZLEmbedAlbumListNavView.titleViewH) / 2,
                width: titleBgControlW,
                height: ZLEmbedAlbumListNavView.titleViewH
            )
            self.albumTitleLabel.frame = CGRect(x: 10, y: 0, width: albumTitleW, height: ZLEmbedAlbumListNavView.titleViewH)
            self.arrow.frame = CGRect(
                x: self.albumTitleLabel.frame.maxX + 5,
                y: (ZLEmbedAlbumListNavView.titleViewH - ZLEmbedAlbumListNavView.arrowH) / 2.0,
                width: ZLEmbedAlbumListNavView.arrowH,
                height: ZLEmbedAlbumListNavView.arrowH
            )
        }
    }
    
    private func setupUI() {
        backgroundColor = .eps.navBarColor
        
        if let effect = EPSPhotoUIConfiguration.default().navViewBlurEffectOfAlbumList {
            navBlurView = UIVisualEffectView(effect: effect)
            addSubview(navBlurView!)
        }
        
        addSubview(titleBgControl)
        titleBgControl.addSubview(albumTitleLabel)
        titleBgControl.addSubview(arrow)
        addSubview(cancelBtn)
    }
    
    @objc private func titleBgControlClick() {
        selectAlbumBlock?()
        if arrow.transform == .identity {
            UIView.animate(withDuration: 0.25) {
                self.arrow.transform = CGAffineTransform(rotationAngle: .pi)
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.arrow.transform = .identity
            }
        }
    }
    
    @objc private func cancelBtnClick() {
        cancelBlock?()
    }
    
    func reset() {
        UIView.animate(withDuration: 0.25) {
            self.arrow.transform = .identity
        }
    }
}

// MARK: external album list nav view

class EPSExternalAlbumListNavView: UIView {
    private let title: String
    
    private var navBlurView: UIVisualEffectView?
    
    private lazy var albumTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .eps.navTitleColor
        label.font = EPSLayout.navTitleFont
        label.text = title
        label.textAlignment = .center
        return label
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        if EPSPhotoUIConfiguration.default().navCancelButtonStyle == .text {
            btn.titleLabel?.font = EPSLayout.navTitleFont
            btn.setTitle(localLanguageTextValue(.cancel), for: .normal)
            btn.setTitleColor(.eps.navTitleColor, for: .normal)
        } else {
            btn.setImage(.eps.getImage("zl_navClose"), for: .normal)
        }
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        
        var image = UIImage.eps.getImage("zl_navBack")
        if isRTL() {
            image = image?.imageFlippedForRightToLeftLayoutDirection()
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        } else {
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        }
        
        btn.setImage(image, for: .normal)
        
        btn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        return btn
    }()
    
    var backBlock: (() -> Void)?
    
    var cancelBlock: (() -> Void)?
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = safeAreaInsets
        }
        
        navBlurView?.frame = bounds
        
        let albumTitleW = min(bounds.width / 2, title.eps.boundingRect(font: EPSLayout.navTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)).width)
        albumTitleLabel.frame = CGRect(x: (bounds.width - albumTitleW) / 2, y: insets.top, width: albumTitleW, height: 44)
        
        var cancelBtnW: CGFloat = 44
        if EPSPhotoUIConfiguration.default().navCancelButtonStyle == .text {
            cancelBtnW = localLanguageTextValue(.cancel)
                .eps.boundingRect(
                    font: EPSLayout.navTitleFont,
                    limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44)
                ).width + 20
        }
        
        if isRTL() {
            backBtn.frame = CGRect(x: bounds.width - insets.right - 60, y: insets.top, width: 60, height: 44)
            cancelBtn.frame = CGRect(x: insets.left + 10, y: insets.top, width: cancelBtnW, height: 44)
        } else {
            backBtn.frame = CGRect(x: insets.left, y: insets.top, width: 60, height: 44)
            cancelBtn.frame = CGRect(x: bounds.width - insets.right - cancelBtnW - 10, y: insets.top, width: cancelBtnW, height: 44)
        }
    }
    
    private func setupUI() {
        backgroundColor = .eps.navBarColor
        
        if let effect = EPSPhotoUIConfiguration.default().navViewBlurEffectOfAlbumList {
            navBlurView = UIVisualEffectView(effect: effect)
            addSubview(navBlurView!)
        }
        
        addSubview(backBtn)
        addSubview(albumTitleLabel)
        addSubview(cancelBtn)
    }
    
    @objc private func backBtnClick() {
        backBlock?()
    }
    
    @objc private func cancelBtnClick() {
        cancelBlock?()
    }
}

class ZLLimitedAuthorityTipsView: UIView {
    static let height: CGFloat = 70
    
    private lazy var icon = UIImageView(image: .eps.getImage("zl_warning"))
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.font = .eps.font(ofSize: 14)
        label.text = localLanguageTextValue(.unableToAccessAllPhotos)
        label.textColor = .eps.limitedAuthorityTipsColor
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var arrow = UIImageView(image: .eps.getImage("zl_right_arrow"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(icon)
        addSubview(tipsLabel)
        addSubview(arrow)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        icon.frame = CGRect(x: 18, y: (ZLLimitedAuthorityTipsView.height - 25) / 2, width: 25, height: 25)
        tipsLabel.frame = CGRect(x: 55, y: (ZLLimitedAuthorityTipsView.height - 40) / 2, width: frame.width - 55 - 30, height: 40)
        arrow.frame = CGRect(x: frame.width - 25, y: (ZLLimitedAuthorityTipsView.height - 12) / 2, width: 12, height: 12)
    }
    
    @objc private func tapAction() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
