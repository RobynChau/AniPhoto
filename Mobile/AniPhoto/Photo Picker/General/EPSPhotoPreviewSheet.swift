//
//  EPSPhotoPreviewSheet.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/11.
//

import UIKit
import Photos

public class EPSPhotoPreviewSheet: UIView {
    private enum Layout {
        static let colH: CGFloat = 155
        
        static let btnH: CGFloat = 45
        
        static let spacing: CGFloat = 1 / UIScreen.main.scale
    }
    
    private lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .eps.rgba(230, 230, 230)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = EPSCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .eps.previewBtnBgColor
        view.delegate = self
        view.dataSource = self
        view.isHidden = self.config.maxPreviewCount == 0
        view.backgroundView = placeholderLabel
        EPSThumbnailPhotoCell.eps.register(view)
        
        return view
    }()
    
    private lazy var cameraBtn: UIButton = {
        let cameraTitle: String
        if !self.config.cameraConfiguration.allowTakePhoto, self.config.cameraConfiguration.allowRecordVideo {
            cameraTitle = localLanguageTextValue(.previewCameraRecord)
        } else {
            cameraTitle = localLanguageTextValue(.previewCamera)
        }
        let btn = createBtn(cameraTitle)
        btn.addTarget(self, action: #selector(cameraBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var photoLibraryBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.previewAlbum))
        btn.addTarget(self, action: #selector(photoLibraryBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = createBtn(localLanguageTextValue(.cancel))
        btn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var flexibleView: UIView = {
        let view = UIView()
        view.backgroundColor = .eps.previewBtnBgColor
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .eps.font(ofSize: 15)
        label.text = localLanguageTextValue(.noPhotoTips)
        label.textAlignment = .center
        label.textColor = .eps.previewBtnTitleColor
        return label
    }()
    
    private var arrDataSources: [EPSPhotoModel] = []
    
    private var arrSelectedModels: [EPSPhotoModel] = []
    
    private var preview = false
    
    private var animate = true
    
    private var senderTabBarIsHidden: Bool?
    
    private var baseViewHeight: CGFloat = 0
    
    private var isSelectOriginal = false
    
    private var panBeginPoint: CGPoint = .zero
    
    private var panImageView: UIImageView?
    
    private var panModel: EPSPhotoModel?
    
    private var panCell: EPSThumbnailPhotoCell?

    private var config: EPSPhotoConfiguration!

    private weak var sender: UIViewController?
    
    private lazy var fetchImageQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    /// Success callback
    /// block params
    ///  - params1: result models
    ///  - params2: is full image
    @objc public var selectImageBlock: (([EPSResultModel], Bool) -> Void)?
    
    /// Callback for photos that failed to parse
    /// block params
    ///  - params1: failed assets.
    ///  - params2: index for asset
    @objc public var selectImageRequestErrorBlock: (([PHAsset], [Int]) -> Void)?
    
    @objc public var cancelBlock: (() -> Void)?
    
    deinit {
        eps_debugPrint("EPSPhotoPreviewSheet deinit")
    }

    /// - Parameter configuration: Sheet configuration
    @objc public convenience init(configuration: EPSPhotoConfiguration? = nil) {
        self.init(frame: .zero)

        self.config = (configuration != nil) ? configuration : self.config

        setupUI()
    }

    /// - Parameter selectedAssets: preselected assets
    @objc public convenience init(selectedAssets: [PHAsset]? = nil) {
        self.init(frame: .zero)
        
        self.config = EPSPhotoConfiguration.default()
        selectedAssets?.eps.removeDuplicate().forEach { asset in
            if !config.allowMixSelect, asset.mediaType == .video {
                return
            }
            
            let m = EPSPhotoModel(asset: asset)
            m.isSelected = true
            self.arrSelectedModels.append(m)
        }
    }
    
    /// Using this init method, you can continue editing the selected photo.
    /// - Note:
    ///     Provided that saveNewImageAfterEdit = false
    /// - Parameters:
    ///    - results : preselected results
    @objc public convenience init(results: [EPSResultModel]? = nil) {
        self.init(frame: .zero)
        
        self.config = EPSPhotoConfiguration.default()
        results?.eps.removeDuplicate().forEach { result in
            if !config.allowMixSelect, result.asset.mediaType == .video {
                return
            }
            
            let m = EPSPhotoModel(asset: result.asset)
            if result.isEdited {
                m.editImage = result.image
                m.editImageModel = result.editModel
            }
            m.isSelected = true
            self.arrSelectedModels.append(m)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.config = EPSPhotoConfiguration.default()

        if !config.allowSelectImage, !config.allowSelectVideo {
            assertionFailure("AniPhoto: error configuration. The values of allowSelectImage and allowSelectVideo are both false")
            config.allowSelectImage = true
        }
        
        setupUI()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        baseView.frame = CGRect(x: 0, y: bounds.height - baseViewHeight, width: bounds.width, height: baseViewHeight)
        
        var btnY: CGFloat = 0
        if self.config.maxPreviewCount > 0 {
            collectionView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: EPSPhotoPreviewSheet.Layout.colH)
            btnY += (collectionView.frame.maxY + EPSPhotoPreviewSheet.Layout.spacing)
        }
        if canShowCameraBtn() {
            cameraBtn.frame = CGRect(x: 0, y: btnY, width: bounds.width, height: EPSPhotoPreviewSheet.Layout.btnH)
            btnY += (EPSPhotoPreviewSheet.Layout.btnH + EPSPhotoPreviewSheet.Layout.spacing)
        }
        photoLibraryBtn.frame = CGRect(x: 0, y: btnY, width: bounds.width, height: EPSPhotoPreviewSheet.Layout.btnH)
        btnY += (EPSPhotoPreviewSheet.Layout.btnH + EPSPhotoPreviewSheet.Layout.spacing)
        cancelBtn.frame = CGRect(x: 0, y: btnY, width: bounds.width, height: EPSPhotoPreviewSheet.Layout.btnH)
        btnY += EPSPhotoPreviewSheet.Layout.btnH
        flexibleView.frame = CGRect(x: 0, y: btnY, width: bounds.width, height: baseViewHeight - btnY)
    }
    
    func setupUI() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .eps.previewBgColor
        
        let showCameraBtn = canShowCameraBtn()
        var btnHeight: CGFloat = 0
        if self.config.maxPreviewCount > 0 {
            btnHeight += EPSPhotoPreviewSheet.Layout.colH
        }
        btnHeight += (EPSPhotoPreviewSheet.Layout.spacing + EPSPhotoPreviewSheet.Layout.btnH) * (showCameraBtn ? 3 : 2)
        btnHeight += deviceSafeAreaInsets().bottom
        baseViewHeight = btnHeight
        
        addSubview(baseView)
        baseView.addSubview(collectionView)
        
        cameraBtn.isHidden = !showCameraBtn
        baseView.addSubview(cameraBtn)
        baseView.addSubview(photoLibraryBtn)
        baseView.addSubview(cancelBtn)
        baseView.addSubview(flexibleView)
        
        if self.config.allowDragSelect {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panSelectAction(_:)))
            baseView.addGestureRecognizer(pan)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    private func createBtn(_ title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .eps.previewBtnBgColor
        btn.setTitleColor(.eps.previewBtnTitleColor, for: .normal)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .eps.font(ofSize: 17)
        return btn
    }
    
    private func canShowCameraBtn() -> Bool {
        if !self.config.cameraConfiguration.allowTakePhoto, !self.config.cameraConfiguration.allowRecordVideo {
            return false
        }
        return true
    }
    
    @objc public func showPreview(animate: Bool = true, sender: UIViewController) {
        show(preview: true, animate: animate, sender: sender)
    }
    
    @objc public func showPhotoLibrary(sender: UIViewController) {
        show(preview: false, animate: false, sender: sender)
    }
    
    /// 传入已选择的assets，并预览
    @objc public func previewAssets(
        sender: UIViewController,
        assets: [PHAsset],
        index: Int,
        isOriginal: Bool,
        showBottomViewAndSelectBtn: Bool = true
    ) {
        assert(!assets.isEmpty, "Assets cannot be empty")
        
        let models = assets.eps.removeDuplicate().map { asset -> EPSPhotoModel in
            let m = EPSPhotoModel(asset: asset)
            m.isSelected = true
            return m
        }
        
        guard !models.isEmpty else {
            return
        }
        
        arrSelectedModels.removeAll()
        arrSelectedModels.append(contentsOf: models)
        self.sender = sender
        isSelectOriginal = isOriginal
        isHidden = true
        sender.view.addSubview(self)
        
        let vc = EPSPhotoPreviewController(photos: models, index: index, showBottomViewAndSelectBtn: showBottomViewAndSelectBtn)
        vc.autoSelectCurrentIfNotSelectAnyone = false
        let nav = getImageNav(rootViewController: vc)
        vc.backBlock = { [weak self] in
            self?.hide { [weak self] in
                self?.cancelBlock?()
            }
        }
        
        sender.showDetailViewController(nav, sender: nil)
    }
    
    private func show(preview: Bool, animate: Bool, sender: UIViewController) {
        self.preview = preview
        self.animate = animate
        self.sender = sender
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted || status == .denied {
            showNoAuthorityAlert()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                EPSMainAsync {
                    if status == .denied {
                        self.showNoAuthorityAlert()
                    } else if status == .authorized {
                        if self.preview {
                            self.loadPhotos()
                            self.show()
                        } else {
                            self.photoLibraryBtnClick()
                        }
                    }
                }
            }
            
            sender.view.addSubview(self)
        } else {
            if preview {
                loadPhotos()
                show()
            } else {
                sender.view.addSubview(self)
                photoLibraryBtnClick()
            }
        }
        
        // Register for the album change notification when the status is limited, because the photoLibraryDidChange method will be repeated multiple times each time the album changes, causing the interface to refresh multiple times. So the album changes are not monitored in other authority.
        if #available(iOS 14.0, *), preview, PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }
    
    private func loadPhotos() {
        EPSPhotoManager.getCameraRollAlbum(allowSelectImage: self.config.allowSelectImage, allowSelectVideo: self.config.allowSelectVideo) { [weak self] cameraRoll in
            guard let `self` = self else { return }
            var totalPhotos = EPSPhotoManager.fetchPhoto(in: cameraRoll.result, ascending: false, allowSelectImage: self.config.allowSelectImage, allowSelectVideo: self.config.allowSelectVideo, limitCount: self.config.maxPreviewCount)
            markSelected(source: &totalPhotos, selected: &self.arrSelectedModels)
            self.arrDataSources.removeAll()
            self.arrDataSources.append(contentsOf: totalPhotos)
            self.collectionView.reloadData()
        }
    }
    
    private func show() {
        frame = sender?.view.bounds ?? .zero
        
        collectionView.contentOffset = .zero
        
        if superview == nil {
            sender?.view.addSubview(self)
        }
        
        if let tabBar = sender?.tabBarController?.tabBar, !tabBar.isHidden {
            senderTabBarIsHidden = tabBar.isHidden
            tabBar.isHidden = true
        }
        
        if animate {
            backgroundColor = .eps.previewBgColor.withAlphaComponent(0)
            var frame = baseView.frame
            frame.origin.y = bounds.height
            baseView.frame = frame
            frame.origin.y -= baseViewHeight
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = .eps.previewBgColor
                self.baseView.frame = frame
            }
        }
    }
    
    private func hide(completion: (() -> Void)? = nil) {
        if animate {
            var frame = baseView.frame
            frame.origin.y += baseViewHeight
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = .eps.previewBgColor.withAlphaComponent(0)
                self.baseView.frame = frame
            }) { _ in
                self.isHidden = true
                completion?()
                self.removeFromSuperview()
            }
        } else {
            isHidden = true
            completion?()
            removeFromSuperview()
        }
        
        if let temp = senderTabBarIsHidden {
            sender?.tabBarController?.tabBar.isHidden = temp
        }
    }
    
    private func showNoAuthorityAlert() {
        if let customAlertWhenNoAuthority = self.config.customAlertWhenNoAuthority {
            customAlertWhenNoAuthority(.library)
            return
        }
        
        let action = EPSCustomAlertAction(title: localLanguageTextValue(.ok), style: .default) { _ in
            self.config.noAuthorityCallback?(.library)
        }
        showAlertController(title: nil, message: String(format: localLanguageTextValue(.noPhotoLibratyAuthority), getAppName()), style: .alert, actions: [action], sender: sender)
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        hide {
            self.cancelBlock?()
        }
    }
    
    @objc private func cameraBtnClick() {
        if config.useCustomCamera {
            let camera = EPSCustomCamera()
            camera.takeDoneBlock = { [weak self] image, videoUrl in
                self?.save(image: image, videoUrl: videoUrl)
                self
            }
            sender?.showDetailViewController(camera, sender: nil)
        } else {
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                showAlertView(localLanguageTextValue(.cameraUnavailable), sender)
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
                sender?.showDetailViewController(picker, sender: nil)
            } else {
                showAlertView(String(format: localLanguageTextValue(.noCameraAuthority), getAppName()), sender)
            }
        }
    }
    
    @objc private func photoLibraryBtnClick() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        animate = false
        showThumbnailViewController()
    }
    
    @objc private func cancelBtnClick() {
        guard !arrSelectedModels.isEmpty else {
            hide { [weak self] in
                self?.cancelBlock?()
            }
            return
        }
        requestSelectPhoto()
    }
    
    @objc private func panSelectAction(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: collectionView)
        if pan.state == .began {
            let cp = baseView.convert(point, from: collectionView)
            guard collectionView.frame.contains(cp) else {
                panBeginPoint = .zero
                return
            }
            panBeginPoint = point
        } else if pan.state == .changed {
            guard panBeginPoint != .zero else {
                return
            }
            
            guard let indexPath = collectionView.indexPathForItem(at: panBeginPoint) else {
                return
            }
            
            if panImageView == nil {
                guard point.y < panBeginPoint.y else {
                    return
                }
                guard let cell = collectionView.cellForItem(at: indexPath) as? EPSThumbnailPhotoCell else {
                    return
                }
                panModel = arrDataSources[indexPath.row]
                panCell = cell
                panImageView = UIImageView(frame: cell.bounds)
                panImageView?.contentMode = .scaleAspectFill
                panImageView?.clipsToBounds = true
                panImageView?.image = cell.imageView.image
                cell.imageView.image = nil
                addSubview(panImageView!)
            }
            panImageView?.center = convert(point, from: collectionView)
        } else if pan.state == .cancelled || pan.state == .ended {
            guard let pv = panImageView else {
                return
            }
            let pvRect = baseView.convert(pv.frame, from: self)
            var callBack = false
            if pvRect.midY < -10 {
                arrSelectedModels.removeAll()
                arrSelectedModels.append(panModel!)
                requestSelectPhoto()
                callBack = true
            }
            
            panModel = nil
            if !callBack {
                let toRect = convert(panCell?.frame ?? .zero, from: collectionView)
                UIView.animate(withDuration: 0.25, animations: {
                    self.panImageView?.frame = toRect
                }) { _ in
                    self.panCell?.imageView.image = self.panImageView?.image
                    self.panCell = nil
                    self.panImageView?.removeFromSuperview()
                    self.panImageView = nil
                }
            } else {
                panCell?.imageView.image = panImageView?.image
                panImageView?.removeFromSuperview()
                panImageView = nil
                panCell = nil
            }
        }
    }
    
    private func requestSelectPhoto(viewController: UIViewController? = nil) {
        guard !arrSelectedModels.isEmpty else {
            selectImageBlock?([], isSelectOriginal)
            hide()
            viewController?.dismiss(animated: true, completion: nil)
            return
        }

        if config.allowMixSelect {
            let videoCount = arrSelectedModels.filter { $0.type == .video }.count
            
            if videoCount > config.maxVideoSelectCount {
                showAlertView(String(format: localLanguageTextValue(.exceededMaxVideoSelectCount), self.config.maxVideoSelectCount), viewController)
                return
            } else if videoCount < config.minVideoSelectCount {
                showAlertView(String(format: localLanguageTextValue(.lessThanMinVideoSelectCount), self.config.minVideoSelectCount), viewController)
                return
            }
        }
        
        let hud = EPSProgressHUD.show(toast: .processing, timeout: EPSPhotoUIConfiguration.default().timeout)
        
        var timeout = false
        hud.timeoutBlock = { [weak self] in
            timeout = true
            showAlertView(localLanguageTextValue(.timeout), viewController ?? self?.sender)
            self?.fetchImageQueue.cancelAllOperations()
        }
        
        let isOriginal = config.allowSelectOriginal ? isSelectOriginal : config.alwaysRequestOriginal
        
        let callback = { [weak self] (sucModels: [EPSResultModel], errorAssets: [PHAsset], errorIndexs: [Int]) in
            hud.hide()
            
            func call() {
                self?.selectImageBlock?(sucModels, isOriginal)
                if !errorAssets.isEmpty {
                    self?.selectImageRequestErrorBlock?(errorAssets, errorIndexs)
                }
            }
            
            if let vc = viewController {
                vc.dismiss(animated: true) {
                    call()
                    self?.hide()
                }
            } else {
                self?.hide {
                    call()
                }
            }
            
            self?.arrSelectedModels.removeAll()
            self?.arrDataSources.removeAll()
        }
        
        var results: [EPSResultModel?] = Array(repeating: nil, count: arrSelectedModels.count)
        var errorAssets: [PHAsset] = []
        var errorIndexs: [Int] = []
        
        var sucCount = 0
        let totalCount = arrSelectedModels.count
        
        for (i, m) in arrSelectedModels.enumerated() {
            let operation = EPSFetchImageOperation(model: m, isOriginal: isOriginal) { image, asset in
                guard !timeout else { return }
                
                sucCount += 1
                
                if let image = image {
                    let isEdited = m.editImage != nil && !self.config.saveNewImageAfterEdit
                    let model = EPSResultModel(
                        asset: asset ?? m.asset,
                        image: image,
                        isEdited: isEdited,
                        editModel: isEdited ? m.editImageModel : nil,
                        index: i
                    )
                    results[i] = model
                    eps_debugPrint("AniPhoto: suc request \(i)")
                } else {
                    errorAssets.append(m.asset)
                    errorIndexs.append(i)
                    eps_debugPrint("AniPhoto: failed request \(i)")
                }
                
                guard sucCount >= totalCount else { return }
                
                callback(
                    results.compactMap { $0 },
                    errorAssets,
                    errorIndexs
                )
            }
            fetchImageQueue.addOperation(operation)
        }
    }
    
    private func showThumbnailViewController() {
        EPSPhotoManager.getCameraRollAlbum(allowSelectImage: self.config.allowSelectImage, allowSelectVideo: self.config.allowSelectVideo) { [weak self] cameraRoll in
            guard let `self` = self else { return }
            let nav: EPSImageNavController
            if EPSPhotoUIConfiguration.default().style == .embedAlbumList {
                let tvc = EPSThumbnailViewController(albumList: cameraRoll)
                nav = self.getImageNav(rootViewController: tvc)
            } else {
                nav = self.getImageNav(rootViewController: EPSAlbumListController())
                let tvc = EPSThumbnailViewController(albumList: cameraRoll)
                nav.pushViewController(tvc, animated: true)
            }
            
            self.sender?.present(nav, animated: true) {
                self.isHidden = true
            }
        }
    }
    
    private func showPreviewController(_ models: [EPSPhotoModel], index: Int) {
        let vc = EPSPhotoPreviewController(photos: models, index: index)
        let nav = getImageNav(rootViewController: vc)
        vc.backBlock = { [weak self, weak nav] in
            guard let `self` = self else { return }
            self.isSelectOriginal = nav?.isSelectedOriginal ?? false
            self.arrSelectedModels.removeAll()
            self.arrSelectedModels.append(contentsOf: nav?.arrSelectedModels ?? [])
            markSelected(source: &self.arrDataSources, selected: &self.arrSelectedModels)
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.changeCancelBtnTitle()
        }
        sender?.showDetailViewController(nav, sender: nil)
    }
    
    private func showEditImageVC(model: EPSPhotoModel) {
        var requestAssetID: PHImageRequestID?
        
        let hud = EPSProgressHUD.show(timeout: EPSPhotoUIConfiguration.default().timeout)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self?.sender)
            if let requestAssetID = requestAssetID {
                PHImageManager.default().cancelImageRequest(requestAssetID)
            }
        }
        
        requestAssetID = EPSPhotoManager.fetchImage(for: model.asset, size: model.previewSize) { [weak self] image, isDegraded in
            if !isDegraded {
                if let image = image {
                    EPSImageEditorViewController.showEditImageVC(parentVC: self?.sender, image: image, editModel: model.editImageModel) { [weak self] ei, editImageModel in
                        model.isSelected = true
                        model.editImage = ei
                        model.editImageModel = editImageModel
                        self?.arrSelectedModels.append(model)
                        self?.config.didSelectAsset?(model.asset)

                        self?.requestSelectPhoto()
                    }
                } else {
                    showAlertView(localLanguageTextValue(.imageLoadFailed), self?.sender)
                }
                hud.hide()
            }
        }
    }
    
    private func showEditVideoVC(model: EPSPhotoModel) {
        var requestAssetID: PHImageRequestID?
        
        let hud = EPSProgressHUD.show(timeout: EPSPhotoUIConfiguration.default().timeout)
        hud.timeoutBlock = { [weak self] in
            showAlertView(localLanguageTextValue(.timeout), self?.sender)
            if let requestAssetID = requestAssetID {
                PHImageManager.default().cancelImageRequest(requestAssetID)
            }
        }
        
        func inner_showEditVideoVC(_ avAsset: AVAsset) {
            let vc = EPSVideoEditorViewController(avAsset: avAsset)
            vc.editFinishBlock = { [weak self] url in
                if let url = url {
                    EPSPhotoManager.saveVideoToAlbum(url: url) { [weak self] suc, asset in
                        if suc, let asset = asset {
                            let m = EPSPhotoModel(asset: asset)
                            m.isSelected = true
                            self?.arrSelectedModels.removeAll()
                            self?.arrSelectedModels.append(m)
                            self?.config.didSelectAsset?(asset)

                            self?.requestSelectPhoto()
                        } else {
                            showAlertView(localLanguageTextValue(.saveVideoError), self?.sender)
                        }
                    }
                } else {
                    self?.arrSelectedModels.removeAll()
                    model.isSelected = true
                    self?.arrSelectedModels.append(model)
                    self?.config.didSelectAsset?(model.asset)

                    self?.requestSelectPhoto()
                }
            }
            vc.modalPresentationStyle = .fullScreen
            sender?.showDetailViewController(vc, sender: nil)
        }
        
        // 提前fetch一下 avasset
        requestAssetID = EPSPhotoManager.fetchAVAsset(forVideo: model.asset) { [weak self] avAsset, _ in
            hud.hide()
            if let avAsset = avAsset {
                inner_showEditVideoVC(avAsset)
            } else {
                showAlertView(localLanguageTextValue(.timeout), self?.sender)
            }
        }
    }
    
    private func getImageNav(rootViewController: UIViewController) -> EPSImageNavController {
        let nav = EPSImageNavController(rootViewController: rootViewController)
        nav.modalPresentationStyle = .fullScreen
        nav.selectImageBlock = { [weak self, weak nav] in
            self?.isSelectOriginal = nav?.isSelectedOriginal ?? false
            self?.arrSelectedModels.removeAll()
            self?.arrSelectedModels.append(contentsOf: nav?.arrSelectedModels ?? [])
            self?.requestSelectPhoto(viewController: nav)
        }
        
        nav.cancelBlock = { [weak self] in
            self?.hide {
                self?.cancelBlock?()
            }
        }
        nav.isSelectedOriginal = isSelectOriginal
        nav.arrSelectedModels.removeAll()
        nav.arrSelectedModels.append(contentsOf: arrSelectedModels)
        
        return nav
    }
    
    private func save(image: UIImage?, videoUrl: URL?) {
        if let image = image {
            let hud = EPSProgressHUD.show(toast: .processing)
            EPSPhotoManager.saveImageToAlbum(image: image) { [weak self] suc, asset in
                hud.hide()
                if suc, let asset = asset {
                    let model = EPSPhotoModel(asset: asset)
                    self?.handleDataArray(newModel: model)
                } else {
                    showAlertView(localLanguageTextValue(.saveImageError), self?.sender)
                }
            }
        } else if let videoUrl = videoUrl {
            let hud = EPSProgressHUD.show(toast: .processing)
            EPSPhotoManager.saveVideoToAlbum(url: videoUrl) { [weak self] suc, asset in
                hud.hide()
                if suc, let at = asset {
                    let model = EPSPhotoModel(asset: at)
                    self?.handleDataArray(newModel: model)
                } else {
                    showAlertView(localLanguageTextValue(.saveVideoError), self?.sender)
                }
            }
        }
    }
    
    private func handleDataArray(newModel: EPSPhotoModel) {
        arrDataSources.insert(newModel, at: 0)

        var canSelect = true
        // If mixed selection is not allowed, and the newModel type is video, it will not be selected.
        if !config.allowMixSelect, newModel.type == .video {
            canSelect = false
        }
        // 单选模式，且不显示选择按钮时，不允许选择
        if config.maxSelectCount == 1, !config.showSelectBtnWhenSingleSelect {
            canSelect = false
        }
        if canSelect, canAddModel(newModel, currentSelectCount: arrSelectedModels.count, sender: sender, showAlert: false) {
            if !shouldDirectEdit(newModel) {
                newModel.isSelected = true
                arrSelectedModels.append(newModel)
                config.didSelectAsset?(newModel.asset)
                
                if config.callbackDirectlyAfterTakingPhoto {
                    requestSelectPhoto()
                    return
                }
            }
        }
        
        let insertIndexPath = IndexPath(row: 0, section: 0)
        collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: [insertIndexPath])
        } completion: { _ in
            self.collectionView.scrollToItem(at: insertIndexPath, at: .centeredHorizontally, animated: true)
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
        
        changeCancelBtnTitle()
    }
}

extension EPSPhotoPreviewSheet: UIGestureRecognizerDelegate {
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        return !baseView.frame.contains(location)
    }
}

extension EPSPhotoPreviewSheet: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let m = arrDataSources[indexPath.row]
        let w = CGFloat(m.asset.pixelWidth)
        let h = CGFloat(m.asset.pixelHeight)
        let scale = min(3.0, max(1.0, w / h))
        return CGSize(width: collectionView.frame.height * scale, height: collectionView.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        placeholderLabel.isHidden = arrSelectedModels.isEmpty
        return arrDataSources.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSThumbnailPhotoCell.eps.identifier, for: indexPath) as! EPSThumbnailPhotoCell

        let model = arrDataSources[indexPath.row]
        
        cell.selectedBlock = { [weak self] block in
            guard let `self` = self else { return }
            
            if !model.isSelected {
                guard canAddModel(model, currentSelectCount: self.arrSelectedModels.count, sender: self.sender) else {
                    return
                }
                
                downloadAssetIfNeed(model: model, sender: self.sender) {
                    if !self.shouldDirectEdit(model) {
                        model.isSelected = true
                        self.arrSelectedModels.append(model)
                        block(true)
                        
                        self.config.didSelectAsset?(model.asset)
                        self.refreshCellIndex()
                        self.changeCancelBtnTitle()
                    }
                }
            } else {
                model.isSelected = false
                self.arrSelectedModels.removeAll { $0 == model }
                block(false)
                
                config.didDeselectAsset?(model.asset)
                self.refreshCellIndex()
                
                self.changeCancelBtnTitle()
            }
        }
        
        if config.showSelectedIndex,
           let index = arrSelectedModels.firstIndex(where: { $0 == model }) {
            setCellIndex(cell, showIndexLabel: true, index: index + config.initialIndex)
        } else {
            cell.indexLabel.isHidden = true
        }
        
        setCellMaskView(cell, isSelected: model.isSelected, model: model)
        
        cell.model = model
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? EPSThumbnailPhotoCell else {
            return
        }
        let model = arrDataSources[indexPath.row]
        setCellMaskView(c, isSelected: model.isSelected, model: model)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EPSThumbnailPhotoCell else {
            return
        }
        
        if !self.config.allowPreviewPhotos {
            cell.btnSelectClick()
            return
        }
        
        if !cell.enableSelect, EPSPhotoUIConfiguration.default().showInvalidMask {
            return
        }
        let model = arrDataSources[indexPath.row]
        
        if shouldDirectEdit(model) {
            return
        }
        
        let uiConfig = EPSPhotoUIConfiguration.default()
        let hud = EPSProgressHUD.show()
        
        EPSPhotoManager.getCameraRollAlbum(allowSelectImage: config.allowSelectImage, allowSelectVideo: config.allowSelectVideo) { [weak self] cameraRoll in
            defer {
                hud.hide()
            }
            
            guard let `self` = self else {
                return
            }
            
            var totalPhotos = EPSPhotoManager.fetchPhoto(
                in: cameraRoll.result,
                ascending: uiConfig.sortAscending,
                allowSelectImage: config.allowSelectImage,
                allowSelectVideo: config.allowSelectVideo
            )
            markSelected(source: &totalPhotos, selected: &self.arrSelectedModels)
            let defaultIndex = uiConfig.sortAscending ? totalPhotos.count - 1 : 0
            var index: Int?
            // last和first效果一样，只是排序方式不同时候分别从前后开始查找可以更快命中
            if uiConfig.sortAscending {
                index = totalPhotos.lastIndex { $0 == model }
            } else {
                index = totalPhotos.firstIndex { $0 == model }
            }
            
            self.showPreviewController(totalPhotos, index: index ?? defaultIndex)
        }
    }
    
    private func shouldDirectEdit(_ model: EPSPhotoModel) -> Bool {

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
        let flag = arrSelectedModels.isEmpty || (arrSelectedModels.count == 1 && arrSelectedModels.first?.ident == model.ident)
        
        if canEditImage, flag {
            showEditImageVC(model: model)
        } else if canEditVideo, flag {
            showEditVideoVC(model: model)
        }
        
        return flag && (canEditImage || canEditVideo)
    }
    
    private func setCellIndex(_ cell: EPSThumbnailPhotoCell?, showIndexLabel: Bool, index: Int) {
        guard self.config.showSelectedIndex else {
            return
        }
        
        cell?.index = index
        cell?.indexLabel.isHidden = !showIndexLabel
    }
    
    private func refreshCellIndex() {
        let uiConfig = EPSPhotoUIConfiguration.default()
        
        let cameraIsEnable = arrSelectedModels.count < config.maxSelectCount
        cameraBtn.alpha = cameraIsEnable ? 1 : 0.3
        cameraBtn.isEnabled = cameraIsEnable
        
        let showIndex = config.showSelectedIndex
        let showMask = uiConfig.showSelectedMask || uiConfig.showInvalidMask
        
        guard showIndex || showMask else {
            return
        }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        visibleIndexPaths.forEach { indexPath in
            guard let cell = collectionView.cellForItem(at: indexPath) as? EPSThumbnailPhotoCell else {
                return
            }
            let m = arrDataSources[indexPath.row]
            
            var show = false
            var idx = 0
            var isSelected = false
            for (index, selM) in arrSelectedModels.enumerated() {
                if m == selM {
                    show = true
                    idx = index + config.initialIndex
                    isSelected = true
                    break
                }
            }
            if showIndex {
                setCellIndex(cell, showIndexLabel: show, index: idx)
            }
            if showMask {
                setCellMaskView(cell, isSelected: isSelected, model: m)
            }
        }
    }
    
    private func setCellMaskView(_ cell: EPSThumbnailPhotoCell, isSelected: Bool, model: EPSPhotoModel) {
        cell.coverView.isHidden = true
        cell.enableSelect = true
        let uiConfig = EPSPhotoUIConfiguration.default()
        
        if isSelected {
            cell.coverView.backgroundColor = .eps.selectedMaskColor
            cell.coverView.isHidden = !uiConfig.showSelectedMask
            if uiConfig.showSelectedBorder {
                cell.layer.borderWidth = 4
            }
        } else {
            let selCount = arrSelectedModels.count
            if selCount < config.maxSelectCount {
                if config.allowMixSelect {
                    let videoCount = arrSelectedModels.filter { $0.type == .video }.count
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
    
    private func changeCancelBtnTitle() {
        if !arrSelectedModels.isEmpty {
            cancelBtn.setTitle(String(format: "%@(%ld)", localLanguageTextValue(.done), arrSelectedModels.count), for: .normal)
            cancelBtn.setTitleColor(.eps.previewBtnHighlightTitleColor, for: .normal)
        } else {
            cancelBtn.setTitle(localLanguageTextValue(.cancel), for: .normal)
            cancelBtn.setTitleColor(.eps.previewBtnTitleColor, for: .normal)
        }
    }
}

extension EPSPhotoPreviewSheet: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            let image = info[.originalImage] as? UIImage
            let url = info[.mediaURL] as? URL
            self.save(image: image, videoUrl: url)
        }
    }
}

extension EPSPhotoPreviewSheet: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        EPSMainAsync {
            self.loadPhotos()
        }
    }
}
