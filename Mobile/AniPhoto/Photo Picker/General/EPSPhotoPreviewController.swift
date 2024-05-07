//
//  EPSPhotoPreviewController.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/20.
//

import UIKit
import Photos

class EPSPhotoPreviewController: UIViewController {
    static let colItemSpacing: CGFloat = 40
    
    static let selPhotoPreviewH: CGFloat = 100
    
    static let previewVCScrollNotification = Notification.Name("previewVCScrollNotification")
    
    let arrDataSources: [EPSPhotoModel]
    
    var currentIndex: Int
    
    lazy var collectionView: UICollectionView = {
        let layout = EPSCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        
        EPSPhotoPreviewCell.eps.register(view)
        EPSGifPreviewCell.eps.register(view)
        EPSLivePhotoPreviewCell.eps.register(view)
        EPSVideoPreviewCell.eps.register(view)
        
        return view
    }()
    
    private let showBottomViewAndSelectBtn: Bool
    
    private var indexBeforOrientationChanged: Int
    
    private let navViewAlpha = 0.95
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear;
//        view.alpha = navViewAlpha
        return view
    }()
    
//    private var navBlurView: UIVisualEffectView?
    
    private lazy var backBtn: UIButton = {
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
    
    private lazy var selectBtn: EPSEnlargeButton = {
        let btn = EPSEnlargeButton(type: .custom)
        btn.setImage(.eps.getImage("zl_btn_unselected_with_check"), for: .normal)
        btn.setImage(.eps.getImage("zl_btn_selected"), for: .selected)
        btn.enlargeInset = 10
        btn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
        return btn
    }()
    
//    private lazy var indexLabel: UILabel = {
//        let label = UILabel()
//        label.backgroundColor = .eps.indexLabelBgColor
//        label.font = .eps.font(ofSize: 14)
//        label.textColor = .white
//        label.textAlignment = .center
//        label.layer.cornerRadius = 25.0 / 2
//        label.layer.masksToBounds = true
//        label.isHidden = true
//        return label
//    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .eps.bottomToolViewBgColorOfPreviewVC
        return view
    }()
    
    private var bottomBlurView: UIVisualEffectView?
    
    private lazy var editBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.edit), #selector(editBtnClick))
        btn.titleLabel?.lineBreakMode = .byCharWrapping
        btn.titleLabel?.numberOfLines = 0
        btn.contentHorizontalAlignment = .left
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
        return btn
    }()
    
    private lazy var originalLabel: UILabel = {
        let label = UILabel()
        label.font = .eps.font(ofSize: 12)
        label.textColor = .eps.originalSizeLabelTextColorOfPreviewVC
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()
    
    private lazy var doneBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.done), #selector(doneBtnClick), true)
        btn.backgroundColor = .eps.bottomToolViewBtnNormalBgColorOfPreviewVC
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = EPSLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    private var selPhotoPreview: ZLPhotoPreviewSelectedView?
    
    private var isFirstAppear = true
    
    private var hideNavView = false
    
    private var popInteractiveTransition: EPSPhotoPreviewPopInteractiveTransition?
    
    private var orientation: UIInterfaceOrientation = .unknown
    
    /// 是否在点击确定时候，当未选择任何照片时候，自动选择当前index的照片
    var autoSelectCurrentIfNotSelectAnyone = true
    
    /// 界面消失时，通知上个界面刷新
    var backBlock: (() -> Void)?
    
    override var prefersStatusBarHidden: Bool {
        !EPSPhotoUIConfiguration.default().showStatusBarInPreviewInterface
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        EPSPhotoUIConfiguration.default().statusBarStyle
    }
    
    deinit {
        eps_debugPrint("EPSPhotoPreviewController deinit")
    }
    
    init(photos: [EPSPhotoModel], index: Int, showBottomViewAndSelectBtn: Bool = true) {
        arrDataSources = photos
        self.showBottomViewAndSelectBtn = showBottomViewAndSelectBtn
        currentIndex = min(index, photos.count - 1)
        indexBeforOrientationChanged = currentIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        addPopInteractiveTransition()
        resetSubviewStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        
        guard isFirstAppear else { return }
        isFirstAppear = false
        
        reloadCurrentCell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = self.view.safeAreaInsets
        }
        insets.top = max(20, insets.top)
        
        collectionView.frame = CGRect(
            x: -EPSPhotoPreviewController.colItemSpacing / 2,
            y: 0,
            width: view.eps.width + EPSPhotoPreviewController.colItemSpacing,
            height: view.eps.height
        )
        
        let navH = insets.top + 44
        navView.frame = CGRect(x: 0, y: 0, width: view.eps.width, height: navH)
//        navBlurView?.frame = navView.bounds
        
        if isRTL() {
            backBtn.frame = CGRect(x: view.eps.width - insets.right - 60, y: insets.top, width: 60, height: 44)
            selectBtn.frame = CGRect(x: insets.left + 15, y: insets.top + (44 - 24) / 2, width: 24, height: 24)
        } else {
            backBtn.frame = CGRect(x: insets.left, y: insets.top, width: 60, height: 44)
            selectBtn.frame = CGRect(x: view.eps.width - 40 - insets.right, y: insets.top + (44 - 24) / 2, width: 24, height: 24)
        }
        
//        indexLabel.frame = selectBtn.bounds
        
        refreshBottomViewFrame()
        
        let ori = UIApplication.shared.statusBarOrientation
        if ori != orientation {
            orientation = ori

            collectionView.setContentOffset(
                CGPoint(
                    x: (view.eps.width + EPSPhotoPreviewController.colItemSpacing) * CGFloat(indexBeforOrientationChanged),
                    y: 0
                ),
                animated: false
            )
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func reloadCurrentCell() {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) else {
            return
        }
        
        if let cell = cell as? EPSGifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? EPSLivePhotoPreviewCell {
            cell.loadLivePhotoData()
        }
    }
    
    private func refreshBottomViewFrame() {
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        var bottomViewH = EPSLayout.bottomToolViewH
        
        var showSelPhotoPreview = false
        if EPSPhotoUIConfiguration.default().showSelectedPhotoPreview,
           let nav = navigationController as? EPSImageNavController,
           !nav.arrSelectedModels.isEmpty {
            showSelPhotoPreview = true
            bottomViewH += EPSPhotoPreviewController.selPhotoPreviewH
            selPhotoPreview?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: EPSPhotoPreviewController.selPhotoPreviewH)
        }
        
        let btnH = EPSLayout.bottomToolBtnH
        
        bottomView.frame = CGRect(x: 0, y: view.frame.height - insets.bottom - bottomViewH, width: view.frame.width, height: bottomViewH + insets.bottom)
        bottomBlurView?.frame = bottomView.bounds
        
        let btnY: CGFloat = showSelPhotoPreview ? EPSPhotoPreviewController.selPhotoPreviewH + EPSLayout.bottomToolBtnY : EPSLayout.bottomToolBtnY
        
        let btnMaxWidth = (bottomView.bounds.width - 30) / 3
        
        let editTitle = localLanguageTextValue(.edit)
        let editBtnW = editTitle.eps.boundingRect(font: EPSLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width
        editBtn.frame = CGRect(x: 15, y: btnY, width: min(btnMaxWidth, editBtnW), height: btnH)
        
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
        
        let doneBtnW = (doneBtn.currentTitle ?? "")
            .eps.boundingRect(
                font: EPSLayout.bottomToolTitleFont,
                limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)
            ).width + 20
        doneBtn.frame = CGRect(x: bottomView.bounds.width - doneBtnW - 15, y: btnY, width: doneBtnW, height: btnH)
    }
    
    private func setupUI() {
        view.backgroundColor = .eps.previewVCBgColor
        automaticallyAdjustsScrollViewInsets = false
        
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        
        view.addSubview(navView)
        
//        if let effect = EPSPhotoUIConfiguration.default().navViewBlurEffectOfPreview {
//            navBlurView = UIVisualEffectView(effect: effect)
//            navView.addSubview(navBlurView!)
//        }
        
        navView.addSubview(backBtn)
        navView.addSubview(selectBtn)
//        selectBtn.addSubview(indexLabel)
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        
        if let effect = EPSPhotoUIConfiguration.default().bottomViewBlurEffectOfPreview {
            bottomBlurView = UIVisualEffectView(effect: effect)
            bottomView.addSubview(bottomBlurView!)
        }
        
        if uiConfig.showSelectedPhotoPreview {
            let selModels = (navigationController as? EPSImageNavController)?.arrSelectedModels ?? []
            selPhotoPreview = ZLPhotoPreviewSelectedView(selModels: selModels, currentShowModel: arrDataSources[currentIndex])
            selPhotoPreview?.selectBlock = { [weak self] model in
                self?.scrollToSelPreviewCell(model)
            }
            selPhotoPreview?.beginSortBlock = { [weak self] in
                self?.resetSubviewStatusWhenDraging(enable: false)
            }
            selPhotoPreview?.endSortBlock = { [weak self] models in
                self?.resetSubviewStatusWhenDraging(enable: true)
                self?.refreshCurrentCellIndex(models)
            }
            bottomView.addSubview(selPhotoPreview!)
        }
        
        editBtn.isHidden = (!config.allowEditImage && !config.allowEditVideo)
        bottomView.addSubview(editBtn)
        
        originalBtn.isHidden = !(config.allowSelectOriginal && config.allowSelectImage)
        originalBtn.isSelected = (navigationController as? EPSImageNavController)?.isSelectedOriginal ?? false
        bottomView.addSubview(originalBtn)
        bottomView.addSubview(originalLabel)
        bottomView.addSubview(doneBtn)
        
        view.bringSubviewToFront(navView)
    }
    
    private func resetSubviewStatusWhenDraging(enable: Bool) {
        collectionView.isScrollEnabled = enable
        navView.isUserInteractionEnabled = enable
        editBtn.isUserInteractionEnabled = enable
        originalBtn.isUserInteractionEnabled = enable
        doneBtn.isUserInteractionEnabled = enable
    }
    
    private func createBtn(_ title: String, _ action: Selector, _ isDone: Bool = false) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = EPSLayout.bottomToolTitleFont
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(
            isDone ? .eps.bottomToolViewDoneBtnNormalTitleColorOfPreviewVC : .eps.bottomToolViewBtnNormalTitleColorOfPreviewVC,
            for: .normal
        )
        btn.setTitleColor(
            isDone ? .eps.bottomToolViewDoneBtnDisableTitleColorOfPreviewVC : .eps.bottomToolViewBtnDisableTitleColorOfPreviewVC,
            for: .disabled
        )
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    private func addPopInteractiveTransition() {
        guard (navigationController?.viewControllers.count ?? 0) > 1 else {
            // 仅有当前vc一个时候，说明不是从相册进入，不添加交互动画
            return
        }
        popInteractiveTransition = EPSPhotoPreviewPopInteractiveTransition(viewController: self)
        popInteractiveTransition?.shouldStartTransition = { [weak self] point -> Bool in
            guard let `self` = self else { return false }
            
            if !self.hideNavView, self.navView.frame.contains(point) ||
                self.bottomView.frame.contains(point) ||
                self.selPhotoPreview?.isDraging == true {
                return false
            }
            
            guard self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) != nil else {
                return false
            }
            
            return true
        }
        popInteractiveTransition?.startTransition = { [weak self] in
            guard let `self` = self else { return }
            
            UIView.animate(withDuration: 0.25) {
                self.navView.alpha = 0
                self.bottomView.alpha = 0
            }
            
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) else {
                return
            }
            
            if let cell = cell as? EPSLivePhotoPreviewCell {
                cell.livePhotoView.stopPlayback()
            } else if let cell = cell as? EPSGifPreviewCell {
                cell.pauseGif()
            }
        }
        popInteractiveTransition?.cancelTransition = { [weak self] in
            guard let `self` = self else { return }
            
            self.hideNavView = false
            self.navView.isHidden = false
            self.bottomView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.navView.alpha = self.navViewAlpha
                self.bottomView.alpha = 1
            }
            
            guard let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) else {
                return
            }
            
            if let cell = cell as? EPSGifPreviewCell {
                cell.resumeGif()
            }
        }
    }
    
    private func resetSubviewStatus() {
        guard let nav = navigationController as? EPSImageNavController else {
            epsLoggerInDebug("Navigation controller is null")
            return
        }
        
        let config = EPSPhotoConfiguration.default()
        let currentModel = arrDataSources[currentIndex]
        
        if (!config.allowMixSelect && currentModel.type == .video) ||
            (!config.showSelectBtnWhenSingleSelect && config.maxSelectCount == 1) {
            selectBtn.isHidden = true
        } else {
            selectBtn.isHidden = false
        }
        selectBtn.isSelected = arrDataSources[currentIndex].isSelected
//        resetIndexLabelStatus()
        
        guard showBottomViewAndSelectBtn else {
            selectBtn.isHidden = true
            bottomView.isHidden = true
            return
        }
        let selCount = nav.arrSelectedModels.count
        var doneTitle = localLanguageTextValue(.done)
        if EPSPhotoConfiguration.default().showSelectCountOnDoneBtn, selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        doneBtn.setTitle(doneTitle, for: .normal)
        
        selPhotoPreview?.isHidden = selCount == 0
        refreshOriginalLabelText()
        refreshBottomViewFrame()
        
        var hideEditBtn = true
        if selCount < config.maxSelectCount || nav.arrSelectedModels.contains(where: { $0 == currentModel }) {
            if config.allowEditImage,
               currentModel.type == .image || (currentModel.type == .gif && !config.allowSelectGif) || (currentModel.type == .livePhoto && !config.allowSelectLivePhoto) {
                hideEditBtn = false
            }
            if config.allowEditVideo,
               currentModel.type == .video,
               selCount == 0 || (selCount == 1 && nav.arrSelectedModels.first == currentModel) {
                hideEditBtn = false
            }
        }
        editBtn.isHidden = hideEditBtn
        
        if EPSPhotoConfiguration.default().allowSelectOriginal,
           EPSPhotoConfiguration.default().allowSelectImage {
            originalBtn.isHidden = !((currentModel.type == .image) || (currentModel.type == .livePhoto && !config.allowSelectLivePhoto) || (currentModel.type == .gif && !config.allowSelectGif))
        }
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
    
//    private func resetIndexLabelStatus() {
//        guard ZLPhotoConfiguration.default().showSelectedIndex else {
//            indexLabel.isHidden = true
//            return
//        }
//        guard let nav = navigationController as? ZLImageNavController else {
//            epsLoggerInDebug("Navigation controller is null")
//            return
//        }
//        if let index = nav.arrSelectedModels.firstIndex(where: { $0 == self.arrDataSources[self.currentIndex] }) {
//            indexLabel.isHidden = false
//            indexLabel.text = String(index + 1)
//        } else {
//            indexLabel.isHidden = true
//        }
//    }
    
    // MARK: btn actions
    
    @objc private func backBtnClick() {
        backBlock?()
        let vc = navigationController?.popViewController(animated: true)
        if vc == nil {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func selectBtnClick() {
        guard let nav = navigationController as? EPSImageNavController else {
            epsLoggerInDebug("Navigation controller is null")
            return
        }
        
        let config = EPSPhotoConfiguration.default()
        
        let currentModel = arrDataSources[currentIndex]
        selectBtn.layer.removeAllAnimations()
        if currentModel.isSelected {
            currentModel.isSelected = false
            nav.arrSelectedModels.removeAll { $0 == currentModel }
            selPhotoPreview?.removeSelModel(model: currentModel)
            
            config.didDeselectAsset?(currentModel.asset)
            
            resetSubviewStatus()
        } else {
            if !canAddModel(currentModel, currentSelectCount: nav.arrSelectedModels.count, sender: self) {
                return
            }
            
            downloadAssetIfNeed(model: currentModel, sender: self) { [weak self] in
                if EPSPhotoUIConfiguration.default().animateSelectBtnWhenSelectInPreviewVC {
                    self?.selectBtn.layer.add(EPSAnimationUtils.springAnimation(), forKey: nil)
                }
                
                currentModel.isSelected = true
                nav.arrSelectedModels.append(currentModel)
                self?.selPhotoPreview?.addSelModel(model: currentModel)
                
                config.didSelectAsset?(currentModel.asset)
                
                self?.resetSubviewStatus()
            }
        }
    }
    
    @objc private func editBtnClick() {
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        
        let model = arrDataSources[currentIndex]
        
        var requestAssetID: PHImageRequestID?
        let hud = EPSProgressHUD(style: uiConfig.hudStyle)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self)
            if let requestAssetID = requestAssetID {
                PHImageManager.default().cancelImageRequest(requestAssetID)
            }
        }
        
        if model.type == .image || (!config.allowSelectGif && model.type == .gif) || (!config.allowSelectLivePhoto && model.type == .livePhoto) {
            hud.show(timeout: EPSPhotoUIConfiguration.default().timeout)
            requestAssetID = EPSPhotoManager.fetchImage(for: model.asset, size: model.previewSize) { [weak self] image, isDegraded in
                if !isDegraded {
                    if let image = image {
                        self?.showEditImageVC(image: image)
                    } else {
                        showAlertView(localLanguageTextValue(.imageLoadFailed), self)
                    }
                    hud.hide()
                }
            }
        } else if model.type == .video || config.allowEditVideo {
            hud.show(timeout: uiConfig.timeout)
            // fetch avasset
            requestAssetID = EPSPhotoManager.fetchAVAsset(forVideo: model.asset) { [weak self] avAsset, _ in
                hud.hide()
                if let avAsset = avAsset {
                    self?.showEditVideoVC(model: model, avAsset: avAsset)
                } else {
                    showAlertView(localLanguageTextValue(.timeout), self)
                }
            }
        }
    }
    
    @objc private func originalPhotoClick() {
        originalBtn.isSelected.toggle()
        
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        
        let nav = (navigationController as? EPSImageNavController)
        nav?.isSelectedOriginal = originalBtn.isSelected
        if nav?.arrSelectedModels.isEmpty == true, originalBtn.isSelected {
            selectBtnClick()
        } else if nav?.arrSelectedModels.isEmpty == false {
            refreshOriginalLabelText()
        }
        
        if config.maxSelectCount == 1,
           !config.showSelectBtnWhenSingleSelect,
           !originalBtn.isSelected,
           nav?.arrSelectedModels.count == 1,
           let currentModel = nav?.arrSelectedModels.first {
            currentModel.isSelected = false
            currentModel.editImage = nil
            currentModel.editImageModel = nil
            nav?.arrSelectedModels.removeAll { $0 == currentModel }
            selPhotoPreview?.removeSelModel(model: currentModel)
            resetSubviewStatus()
            let index = uiConfig.sortAscending ? arrDataSources.lastIndex { $0 == currentModel } : arrDataSources.firstIndex { $0 == currentModel }
            if let index = index {
                collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
    
    @objc private func doneBtnClick() {
        guard let nav = navigationController as? EPSImageNavController else {
            epsLoggerInDebug("Navigation controller is null")
            return
        }
        
        func callBackBeforeDone() {
            if let block = EPSPhotoConfiguration.default().operateBeforeDoneAction {
                block(self) { [weak nav] in
                    nav?.selectImageBlock?()
                }
            } else {
                nav.selectImageBlock?()
            }
        }
        
        let currentModel = arrDataSources[currentIndex]
        
        guard autoSelectCurrentIfNotSelectAnyone, nav.arrSelectedModels.isEmpty else {
            callBackBeforeDone()
            return
        }
        
        guard canAddModel(currentModel, currentSelectCount: nav.arrSelectedModels.count, sender: self) else {
            return
        }
        
        downloadAssetIfNeed(model: currentModel, sender: self) { [weak nav] in
            nav?.arrSelectedModels.append(currentModel)
            EPSPhotoConfiguration.default().didSelectAsset?(currentModel.asset)
            
            callBackBeforeDone()
        }
    }
    
    private func scrollToSelPreviewCell(_ model: EPSPhotoModel) {
        guard let index = arrDataSources.lastIndex(of: model) else {
            return
        }
        collectionView.performBatchUpdates({
            self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }) { _ in
            self.indexBeforOrientationChanged = self.currentIndex
            self.reloadCurrentCell()
        }
    }
    
    private func refreshCurrentCellIndex(_ models: [EPSPhotoModel]) {
        let nav = navigationController as? EPSImageNavController
        nav?.arrSelectedModels.removeAll()
        nav?.arrSelectedModels.append(contentsOf: models)
        guard EPSPhotoConfiguration.default().showSelectedIndex else {
            return
        }
//        resetIndexLabelStatus()
    }
    
    private func tapPreviewCell() {
        hideNavView.toggle()
        
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
        if let cell = cell as? EPSVideoPreviewCell, cell.isPlaying {
            hideNavView = true
        }
        navView.isHidden = hideNavView
        bottomView.isHidden = showBottomViewAndSelectBtn ? hideNavView : true
    }
    
    private func showEditImageVC(image: UIImage) {
        let model = arrDataSources[currentIndex]
        let nav = navigationController as? EPSImageNavController
        EPSImageEditorViewController.showEditImageVC(parentVC: self, image: image, editModel: model.editImageModel) { [weak self, weak nav] editImage, editImageModel in
            guard let `self` = self else { return }
            model.editImage = editImage
            model.editImageModel = editImageModel
            if nav?.arrSelectedModels.contains(where: { $0 == model }) == false {
                model.isSelected = true
                nav?.arrSelectedModels.append(model)
                self.resetSubviewStatus()
                self.selPhotoPreview?.addSelModel(model: model)
            } else {
                self.selPhotoPreview?.refreshCell(for: model)
            }
            self.collectionView.reloadItems(at: [IndexPath(row: self.currentIndex, section: 0)])
        }
    }
    
    private func showEditVideoVC(model: EPSPhotoModel, avAsset: AVAsset) {
        let nav = navigationController as? EPSImageNavController
        let vc = EPSVideoEditorViewController(avAsset: avAsset)
        vc.modalPresentationStyle = .fullScreen
        
        vc.editFinishBlock = { [weak self, weak nav] url in
            if let url = url {
                EPSPhotoManager.saveVideoToAlbum(url: url) { [weak self, weak nav] suc, asset in
                    if suc, asset != nil {
                        let m = EPSPhotoModel(asset: asset!)
                        nav?.arrSelectedModels.removeAll()
                        nav?.arrSelectedModels.append(m)
                        nav?.selectImageBlock?()
                    } else {
                        showAlertView(localLanguageTextValue(.saveVideoError), self)
                    }
                }
            } else {
                nav?.arrSelectedModels.removeAll()
                nav?.arrSelectedModels.append(model)
                nav?.selectImageBlock?()
            }
        }
        
        present(vc, animated: false, completion: nil)
    }
}

extension EPSPhotoPreviewController: UINavigationControllerDelegate {
    func navigationController(_: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from _: UIViewController, to _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return nil
        }
        
        return popInteractiveTransition?.interactive == true ? EPSPhotoPreviewAnimatedTransition() : nil
    }
    
    func navigationController(_: UINavigationController, interactionControllerFor _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return popInteractiveTransition?.interactive == true ? popInteractiveTransition : nil
    }
}

// MARK: scroll view delegate

extension EPSPhotoPreviewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else {
            return
        }
        
        NotificationCenter.default.post(name: EPSPhotoPreviewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (view.bounds.width + EPSPhotoPreviewController.colItemSpacing)))
        page = max(0, min(page, arrDataSources.count - 1))
        if page == currentIndex {
            return
        }
        currentIndex = page
        resetSubviewStatus()
        selPhotoPreview?.changeCurrentModel(to: arrDataSources[currentIndex])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        indexBeforOrientationChanged = currentIndex
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
        if let cell = cell as? EPSGifPreviewCell {
            cell.loadGifWhenCellDisplaying()
        } else if let cell = cell as? EPSLivePhotoPreviewCell {
            cell.loadLivePhotoData()
        }
    }
}

extension EPSPhotoPreviewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return EPSPhotoPreviewController.colItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return EPSPhotoPreviewController.colItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: EPSPhotoPreviewController.colItemSpacing / 2, bottom: 0, right: EPSPhotoPreviewController.colItemSpacing / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.eps.width, height: view.eps.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrDataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = EPSPhotoConfiguration.default()
        let model = arrDataSources[indexPath.row]
        
        let baseCell: EPSPreviewBaseCell
        
        if config.allowSelectGif, model.type == .gif {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSGifPreviewCell.eps.identifier, for: indexPath) as! EPSGifPreviewCell
            
            cell.singleTapBlock = { [weak self] in
                self?.tapPreviewCell()
            }
            
            cell.model = model
            
            baseCell = cell
        } else if config.allowSelectLivePhoto, model.type == .livePhoto {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSLivePhotoPreviewCell.eps.identifier, for: indexPath) as! EPSLivePhotoPreviewCell
            
            cell.model = model
            
            baseCell = cell
        } else if config.allowSelectVideo, model.type == .video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSVideoPreviewCell.eps.identifier, for: indexPath) as! EPSVideoPreviewCell
            
            cell.model = model
            
            baseCell = cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSPhotoPreviewCell.eps.identifier, for: indexPath) as! EPSPhotoPreviewCell

            cell.singleTapBlock = { [weak self] in
                self?.tapPreviewCell()
            }

            cell.model = model

            baseCell = cell
        }
        
        baseCell.singleTapBlock = { [weak self] in
            self?.tapPreviewCell()
        }
        
        return baseCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? EPSPreviewBaseCell)?.willDisplay()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? EPSPreviewBaseCell)?.didEndDisplaying()
    }
}

// MARK: 下方显示的已选择照片列表

// UICollectionViewDragDelegate, UICollectionViewDropDelegate
class ZLPhotoPreviewSelectedView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    private lazy var collectionView: UICollectionView = {
        let layout = EPSCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        ZLPhotoPreviewSelectedViewCell.eps.register(view)
        
//        if #available(iOS 11.0, *) {
//            view.dragDelegate = self
//            view.dropDelegate = self
//            view.dragInteractionEnabled = true
//            view.isSpringLoaded = true
//        } else {
//            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
//            view.addGestureRecognizer(longPressGesture)
//        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPressGesture.delegate = self
        view.addGestureRecognizer(longPressGesture)
        
        return view
    }()
    
    private var arrSelectedModels: [EPSPhotoModel]
    
    private var currentShowModel: EPSPhotoModel
    
    var isDraging = false
    
    var selectBlock: ((EPSPhotoModel) -> Void)?
    
    var beginSortBlock: (() -> Void)?
    
    var endSortBlock: (([EPSPhotoModel]) -> Void)?
    
    init(selModels: [EPSPhotoModel], currentShowModel: EPSPhotoModel) {
        arrSelectedModels = selModels
        self.currentShowModel = currentShowModel
        super.init(frame: .zero)
        
        setupUI()
    }
    
    private func setupUI() {
        addSubview(collectionView)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = CGRect(x: 0, y: 10, width: bounds.width, height: 80)
        if let index = arrSelectedModels.firstIndex(where: { $0 == self.currentShowModel }) {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func changeCurrentModel(to model: EPSPhotoModel) {
        guard currentShowModel != model else {
            return
        }
        currentShowModel = model
        
        if let index = arrSelectedModels.firstIndex(where: { $0 == self.currentShowModel }) {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
            collectionView.reloadData()
        } else {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }
    
    func addSelModel(model: EPSPhotoModel) {
        arrSelectedModels.append(model)
        let indexPath = IndexPath(row: arrSelectedModels.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func removeSelModel(model: EPSPhotoModel) {
        guard let index = arrSelectedModels.firstIndex(where: { $0 == model }) else {
            return
        }
        arrSelectedModels.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    func refreshCell(for model: EPSPhotoModel) {
        guard let index = arrSelectedModels.firstIndex(where: { $0 == model }) else {
            return
        }
        collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    // MARK: iOS10 拖动
    
    @objc func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            isDraging = true
            beginSortBlock?()
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        } else if gesture.state == .changed {
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        } else if gesture.state == .ended {
            isDraging = false
            collectionView.endInteractiveMovement()
            endSortBlock?(arrSelectedModels)
        } else {
            isDraging = false
            collectionView.cancelInteractiveMovement()
            endSortBlock?(arrSelectedModels)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveModel = arrSelectedModels[sourceIndexPath.row]
        arrSelectedModels.remove(at: sourceIndexPath.row)
        arrSelectedModels.insert(moveModel, at: destinationIndexPath.row)
    }
    
    // MARK: iOS11 拖动

    // iOS11 拖动cell后，部分cell无法点击，先不用这种方式
//    @available(iOS 11.0, *)
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        isDraging = true
//        let itemProvider = NSItemProvider()
//        let item = UIDragItem(itemProvider: itemProvider)
//        return [item]
//    }
//
//    @available(iOS 11.0, *)
//    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
//        if collectionView.hasActiveDrag {
//            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//        }
//        return UICollectionViewDropProposal(operation: .forbidden)
//    }
//
//    @available(iOS 11.0, *)
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        isDraging = false
//        guard coordinator.proposal.operation == .move,
//              let destinationIndexPath = coordinator.destinationIndexPath,
//              let item = coordinator.items.first,
//              let sourceIndexPath = item.sourceIndexPath else {
//            return
//        }
//
//        let moveModel = arrSelectedModels[sourceIndexPath.row]
//        arrSelectedModels.remove(at: sourceIndexPath.row)
//        arrSelectedModels.insert(moveModel, at: destinationIndexPath.row)
//
//        collectionView.performBatchUpdates {
//            collectionView.deleteItems(at: [sourceIndexPath])
//            collectionView.insertItems(at: [destinationIndexPath])
//        } completion: { _ in
//            self.collectionView.reloadData()
//        }
//
//        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
//        endSortBlock?(arrSelectedModels)
//    }
//
//    @available(iOS 11.0, *)
//    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
//        isDraging = false
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSelectedModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLPhotoPreviewSelectedViewCell.eps.identifier, for: indexPath) as! ZLPhotoPreviewSelectedViewCell
        
        let m = arrSelectedModels[indexPath.row]
        cell.model = m
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isDraging else { return }
        
        let m = arrSelectedModels[indexPath.row]
        currentShowModel = m
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
        
        selectBlock?(m)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let m = arrSelectedModels[indexPath.row]
        if m == currentShowModel {
            cell.layer.borderWidth = 4
        } else {
            cell.layer.borderWidth = 0
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let indexPath = collectionView.indexPathForItem(at: gestureRecognizer.location(in: collectionView))
        return indexPath != nil
    }
}

class ZLPhotoPreviewSelectedViewCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var tagImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.font = .eps.font(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    private var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    private var imageIdentifier = ""
    
    var model: EPSPhotoModel! {
        didSet {
            self.configureCell()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.eps.bottomToolViewBtnNormalBgColorOfPreviewVC.cgColor
        
        contentView.addSubview(imageView)
        contentView.addSubview(tagImageView)
        contentView.addSubview(tagLabel)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        tagImageView.frame = CGRect(x: 5, y: bounds.height - 25, width: 20, height: 20)
        tagLabel.frame = CGRect(x: 5, y: bounds.height - 25, width: bounds.width - 10, height: 20)
    }
    
    private func configureCell() {
        let size = CGSize(width: bounds.width * 1.5, height: bounds.height * 1.5)
        
        if imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        
        if model.type == .video {
            tagImageView.isHidden = false
            tagImageView.image = .eps.getImage("zl_video")
            tagLabel.isHidden = true
        } else if EPSPhotoConfiguration.default().allowSelectGif, model.type == .gif {
            tagImageView.isHidden = true
            tagLabel.isHidden = false
            tagLabel.text = "GIF"
        } else if EPSPhotoConfiguration.default().allowSelectLivePhoto, model.type == .livePhoto {
            tagImageView.isHidden = false
            tagImageView.image = .eps.getImage("zl_livePhoto")
            tagLabel.isHidden = true
        } else {
            if let _ = model.editImage {
                tagImageView.isHidden = false
                tagImageView.image = .eps.getImage("zl_editImage_tag")
            } else {
                tagImageView.isHidden = true
                tagLabel.isHidden = true
            }
        }
        
        imageIdentifier = model.ident
        imageView.image = nil
        
        if let ei = model.editImage {
            imageView.image = ei
        } else {
            imageRequestID = EPSPhotoManager.fetchImage(for: model.asset, size: size, completion: { [weak self] image, _ in
                if self?.imageIdentifier == self?.model.ident {
                    self?.imageView.image = image
                }
            })
        }
    }
}
