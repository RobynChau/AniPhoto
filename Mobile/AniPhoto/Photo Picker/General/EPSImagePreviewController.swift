//
//  EPSImagePreviewController.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/10/22.
//

import UIKit
import Photos

@objc public enum EPSURLType: Int {
    case image
    case video
}

public typealias EPSImageLoaderBlock = (_ url: URL, _ imageView: UIImageView, _ progress: @escaping (CGFloat) -> Void, _ complete: @escaping () -> Void) -> Void

public class EPSImagePreviewController: UIViewController {
    static let colItemSpacing: CGFloat = 40
    
    static let selPhotoPreviewH: CGFloat = 100
    
    private let datas: [Any]
    
    private var selectStatus: [Bool]
    
    private let urlType: ((URL) -> EPSURLType)?
    
    private let urlImageLoader: EPSImageLoaderBlock?
    
    private let showSelectBtn: Bool
    
    private let showBottomView: Bool

    private var currentIndex: Int
    
    private var indexBeforOrientationChanged: Int
    
    private lazy var collectionView: UICollectionView = {
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
        EPSLocalImagePreviewCell.eps.register(view)
        EPSNetImagePreviewCell.eps.register(view)
        EPSNetVideoPreviewCell.eps.register(view)
        
        return view
    }()
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .eps.navBarColorOfPreviewVC
        return view
    }()
    
    private var navBlurView: UIVisualEffectView?
    
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
    
    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .eps.indexLabelTextColor
        label.font = EPSLayout.navTitleFont
        label.textAlignment = .center
        return label
    }()
    
    private lazy var selectBtn: EPSEnlargeButton = {
        let btn = EPSEnlargeButton(type: .custom)
        btn.setImage(.eps.getImage("zl_btn_unselected_with_check"), for: .normal)
        btn.setImage(.eps.getImage("zl_btn_selected"), for: .selected)
        btn.enlargeInset = 10
        btn.addTarget(self, action: #selector(selectBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .eps.bottomToolViewBgColorOfPreviewVC
        return view
    }()
    
    private var bottomBlurView: UIVisualEffectView?
    
    private lazy var doneBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = EPSLayout.bottomToolTitleFont
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.eps.bottomToolViewDoneBtnNormalTitleColorOfPreviewVC, for: .normal)
        btn.setTitleColor(.eps.bottomToolViewDoneBtnDisableTitleColorOfPreviewVC, for: .disabled)
        btn.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)
        btn.backgroundColor = .eps.bottomToolViewBtnNormalBgColorOfPreviewVC
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = EPSLayout.bottomToolBtnCornerRadius
        return btn
    }()
    
    private var isFirstAppear = true
    
    private var hideNavView = false
    
    private var orientation: UIInterfaceOrientation = .unknown
    
    @objc public var longPressBlock: ((EPSImagePreviewController?, UIImage?, Int) -> Void)?
    
    @objc public var doneBlock: (([Any]) -> Void)?
    
    @objc public var videoHttpHeader: [String: Any]?
    
    override public var prefersStatusBarHidden: Bool {
        !EPSPhotoUIConfiguration.default().showStatusBarInPreviewInterface
    }
    
    override public var prefersHomeIndicatorAutoHidden: Bool { true }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        EPSPhotoUIConfiguration.default().statusBarStyle
    }
    
    deinit {
        eps_debugPrint("EPSImagePreviewController deinit")
    }
    
    /// - Parameters:
    ///   - datas: Must be one of PHAsset, UIImage and URL, will filter others in init function.
    ///   - showBottomView: If showSelectBtn is true, showBottomView is always true.
    ///   - index: Index for first display.
    ///   - urlType: Tell me the url is image or video.
    ///   - urlImageLoader: Called when cell will display, cell will layout after callback when image load finish. The first block is progress callback, second is load finish callback.
    @objc public init(
        datas: [Any],
        index: Int = 0,
        showSelectBtn: Bool = true,
        showBottomView: Bool = true,
        urlType: ((URL) -> EPSURLType)? = nil,
        urlImageLoader: EPSImageLoaderBlock? = nil
    ) {
        let filterDatas = datas.filter { $0 is PHAsset || $0 is UIImage || $0 is URL }
        self.datas = filterDatas
        selectStatus = Array(repeating: true, count: filterDatas.count)
        currentIndex = min(index, filterDatas.count - 1)
        indexBeforOrientationChanged = currentIndex
        self.showSelectBtn = showSelectBtn
        self.showBottomView = showSelectBtn ? true : showBottomView
        self.urlType = urlType
        self.urlImageLoader = urlImageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        resetSubViewStatus()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirstAppear else {
            return
        }
        isFirstAppear = false
        
        reloadCurrentCell()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
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
        navBlurView?.frame = navView.bounds
        
        indexLabel.frame = CGRect(x: (view.eps.width - 80) / 2, y: insets.top, width: 80, height: 44)
        
        if isRTL() {
            backBtn.frame = CGRect(x: view.eps.width - insets.right - 60, y: insets.top, width: 60, height: 44)
            selectBtn.frame = CGRect(x: insets.left + 15, y: insets.top + (44 - 25) / 2, width: 25, height: 25)
        } else {
            backBtn.frame = CGRect(x: insets.left, y: insets.top, width: 60, height: 44)
            selectBtn.frame = CGRect(x: view.eps.width - 40 - insets.right, y: insets.top + (44 - 25) / 2, width: 25, height: 25)
        }
        
        let bottomViewH = EPSLayout.bottomToolViewH
        
        bottomView.frame = CGRect(x: 0, y: view.eps.height - insets.bottom - bottomViewH, width: view.eps.width, height: bottomViewH + insets.bottom)
        bottomBlurView?.frame = bottomView.bounds
        
        resetBottomViewFrame()
        
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
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
    
    private func setupUI() {
        view.backgroundColor = .eps.previewVCBgColor
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(navView)
        
        if let effect = EPSPhotoUIConfiguration.default().navViewBlurEffectOfPreview {
            navBlurView = UIVisualEffectView(effect: effect)
            navView.addSubview(navBlurView!)
        }
        
        navView.addSubview(backBtn)
        navView.addSubview(indexLabel)
        navView.addSubview(selectBtn)
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        
        if let effect = EPSPhotoUIConfiguration.default().bottomViewBlurEffectOfPreview {
            bottomBlurView = UIVisualEffectView(effect: effect)
            bottomView.addSubview(bottomBlurView!)
        }
        
        bottomView.addSubview(doneBtn)
        view.bringSubviewToFront(navView)
    }
    
    private func resetSubViewStatus() {
        indexLabel.text = String(currentIndex + 1) + " / " + String(datas.count)
        
        if showSelectBtn {
            selectBtn.isSelected = selectStatus[currentIndex]
        } else {
            selectBtn.isHidden = true
        }
        
        resetBottomViewFrame()
    }
    
    private func resetBottomViewFrame() {
        guard showBottomView else {
            bottomView.isHidden = true
            return
        }
        
        let btnY = EPSLayout.bottomToolBtnY
        
        var doneTitle = localLanguageTextValue(.done)
        let selCount = selectStatus.filter { $0 }.count
        if showSelectBtn,
           EPSPhotoConfiguration.default().showSelectCountOnDoneBtn,
           selCount > 0 {
            doneTitle += "(" + String(selCount) + ")"
        }
        let doneBtnW = doneTitle.eps.boundingRect(font: EPSLayout.bottomToolTitleFont, limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)).width + 20
        doneBtn.frame = CGRect(x: bottomView.bounds.width - doneBtnW - 15, y: btnY, width: doneBtnW, height: EPSLayout.bottomToolBtnH)
        doneBtn.setTitle(doneTitle, for: .normal)
    }
    
    private func dismiss() {
        if let nav = navigationController {
            let vc = nav.popViewController(animated: true)
            if vc == nil {
                nav.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: btn actions
    
    @objc private func backBtnClick() {
        dismiss()
    }
    
    @objc private func selectBtnClick() {
        var isSelected = selectStatus[currentIndex]
        selectBtn.layer.removeAllAnimations()
        if isSelected {
            isSelected = false
        } else {
            if EPSPhotoUIConfiguration.default().animateSelectBtnWhenSelectInPreviewVC {
                selectBtn.layer.add(EPSAnimationUtils.springAnimation(), forKey: nil)
            }
            isSelected = true
        }
        
        selectStatus[currentIndex] = isSelected
        resetSubViewStatus()
    }
    
    @objc private func doneBtnClick() {
        if showSelectBtn {
            let res = datas.enumerated()
                .filter { self.selectStatus[$0.offset] }
                .map { $0.element }
            
            doneBlock?(res)
        } else {
            doneBlock?(datas)
        }
        
        dismiss()
    }
    
    private func tapPreviewCell() {
        hideNavView.toggle()
        
        let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0))
        if let cell = cell as? EPSVideoPreviewCell, cell.isPlaying {
            hideNavView = true
        }
        navView.isHidden = hideNavView
        if showBottomView {
            bottomView.isHidden = hideNavView
        }
    }
}

// scroll view delegate
public extension EPSImagePreviewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else {
            return
        }
        
        NotificationCenter.default.post(name: EPSPhotoPreviewController.previewVCScrollNotification, object: nil)
        let offset = scrollView.contentOffset
        var page = Int(round(offset.x / (view.bounds.width + EPSPhotoPreviewController.colItemSpacing)))
        page = max(0, min(page, datas.count - 1))
        if page == currentIndex {
            return
        }
        
        currentIndex = page
        resetSubViewStatus()
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

extension EPSImagePreviewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return EPSImagePreviewController.colItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return EPSImagePreviewController.colItemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: EPSImagePreviewController.colItemSpacing / 2, bottom: 0, right: EPSImagePreviewController.colItemSpacing / 2)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.eps.width, height: view.eps.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config = EPSPhotoConfiguration.default()
        let obj = datas[indexPath.row]
        
        let baseCell: EPSPreviewBaseCell
        
        if let asset = obj as? PHAsset {
            let model = EPSPhotoModel(asset: asset)
            
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
            
            return baseCell
        } else if let image = obj as? UIImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSLocalImagePreviewCell.eps.identifier, for: indexPath) as! EPSLocalImagePreviewCell
            
            cell.image = image
            
            baseCell = cell
        } else if let url = obj as? URL {
            let type: EPSURLType = urlType?(url) ?? .image
            if type == .image {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSNetImagePreviewCell.eps.identifier, for: indexPath) as! EPSNetImagePreviewCell
                cell.image = nil
                
                urlImageLoader?(url, cell.preview.imageView, { [weak cell] progress in
                    EPSMainAsync {
                        cell?.progress = progress
                    }
                }, { [weak cell] in
                    EPSMainAsync {
                        cell?.preview.resetSubViewSize()
                    }
                })
                
                baseCell = cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EPSNetVideoPreviewCell.eps.identifier, for: indexPath) as! EPSNetVideoPreviewCell
                
                cell.configureCell(videoUrl: url, httpHeader: videoHttpHeader)
                
                baseCell = cell
            }
        } else {
            #if DEBUG
                fatalError("Preview obj must one of PHAsset, UIImage, URL")
            #else
                return UICollectionViewCell()
            #endif
        }
        
        baseCell.singleTapBlock = { [weak self] in
            self?.tapPreviewCell()
        }
        
        (baseCell as? EPSLocalImagePreviewCell)?.longPressBlock = { [weak self, weak baseCell] in
            if let callback = self?.longPressBlock {
                callback(self, baseCell?.currentImage, indexPath.row)
            } else {
                self?.showSaveImageAlert()
            }
        }
        
        return baseCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? EPSPreviewBaseCell)?.willDisplay()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? EPSPreviewBaseCell)?.didEndDisplaying()
    }
    
    private func showSaveImageAlert() {
        func saveImage() {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: currentIndex, section: 0)) as? EPSLocalImagePreviewCell, let image = cell.currentImage else {
                return
            }
            
            let hud = EPSProgressHUD.show(toast: .processing)
            EPSPhotoManager.saveImageToAlbum(image: image) { [weak self] suc, _ in
                hud.hide()
                if !suc {
                    showAlertView(localLanguageTextValue(.saveImageError), self)
                }
            }
        }
        
        let saveAction = EPSCustomAlertAction(title: localLanguageTextValue(.save), style: .default) { _ in
            saveImage()
        }
        let cancelAction = EPSCustomAlertAction(title: localLanguageTextValue(.cancel), style: .cancel, handler: nil)
        showAlertController(title: nil, message: "", style: .actionSheet, actions: [saveAction, cancelAction], sender: self)
    }
}
