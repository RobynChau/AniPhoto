//
//  EPSThumbnailPhotoCell.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/12.
//

import UIKit
import Photos

class EPSThumbnailPhotoCell: UICollectionViewCell {
    private let selectBtnWH: CGFloat = 24
    
    private lazy var containerView = UIView()
    
    private lazy var bottomShadowView = UIImageView(image: .eps.getImage("zl_shadow"))
    
    private lazy var videoTag = UIImageView(image: .eps.getImage("zl_video"))
    
    private lazy var livePhotoTag = UIImageView(image: .eps.getImage("zl_livePhoto"))
    
    private lazy var editImageTag = UIImageView(image: .eps.getImage("zl_editImage_tag"))
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = .eps.font(ofSize: 13)
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    
    private lazy var progressView: EPSProgressView = {
        let view = EPSProgressView()
        view.isHidden = true
        return view
    }()
    
    private var imageIdentifier = ""
    
    private var smallImageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    private var bigImageReqeustID: PHImageRequestID = PHInvalidImageRequestID
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    lazy var btnSelect: EPSEnlargeButton = {
        let btn = EPSEnlargeButton(type: .custom)
        btn.setBackgroundImage(.eps.getImage("zl_btn_unselected"), for: .normal)
        btn.setBackgroundImage(.eps.getImage("zl_btn_selected"), for: .selected)
        btn.addTarget(self, action: #selector(btnSelectClick), for: .touchUpInside)
        btn.enlargeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 5)
        return btn
    }()
    
    lazy var coverView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()
    
    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .eps.indexLabelTextColor
        label.backgroundColor = .eps.indexLabelBgColor
        if EPSPhotoUIConfiguration.default().showIndexOnSelectBtn {
            label.font = .eps.font(ofSize: 14)
            label.textAlignment = .center
            label.layer.cornerRadius = selectBtnWH / 2
            label.layer.masksToBounds = true
        } else {
            label.font = .eps.font(ofSize: 14, bold: true)
            label.textAlignment = .left
        }
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    var enableSelect = true {
        didSet {
            containerView.alpha = enableSelect ? 1 : 0.2
        }
    }
    
    var selectedBlock: ((@escaping (Bool) -> Void) -> Void)?
    
    var model: EPSPhotoModel! {
        didSet {
            configureCell()
        }
    }
    
    var index = 0 {
        didSet {
            indexLabel.text = String(index)
        }
    }
    
    deinit {
        eps_debugPrint("EPSThumbnailPhotoCell deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(coverView)
        contentView.addSubview(containerView)
        containerView.addSubview(btnSelect)
        containerView.addSubview(indexLabel)
        containerView.addSubview(bottomShadowView)
        bottomShadowView.addSubview(videoTag)
        bottomShadowView.addSubview(livePhotoTag)
        bottomShadowView.addSubview(editImageTag)
        bottomShadowView.addSubview(descLabel)
        containerView.addSubview(progressView)
        
        if EPSPhotoUIConfiguration.default().showSelectedBorder {
            layer.borderColor = UIColor.eps.selectedBorderColor.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        containerView.frame = bounds
        coverView.frame = bounds
        btnSelect.frame = CGRect(x: bounds.width - 32, y: 8, width: selectBtnWH, height: selectBtnWH)
        if EPSPhotoUIConfiguration.default().showIndexOnSelectBtn {
            indexLabel.frame = btnSelect.frame
        } else {
            indexLabel.frame = CGRect(x: 8, y: 5, width: 50, height: selectBtnWH)
        }
        
        bottomShadowView.frame = CGRect(x: 0, y: bounds.height - 25, width: bounds.width, height: 25)
        videoTag.frame = CGRect(x: 5, y: 1, width: 20, height: 15)
        livePhotoTag.frame = CGRect(x: 5, y: -1, width: 20, height: 20)
        editImageTag.frame = CGRect(x: 5, y: -1, width: 20, height: 20)
        descLabel.frame = CGRect(x: 30, y: 1, width: bounds.width - 35, height: 17)
        progressView.frame = CGRect(x: (bounds.width - 20) / 2, y: (bounds.height - 20) / 2, width: 20, height: 20)
    }
    
    @objc func btnSelectClick() {
        selectedBlock?({ [weak self] isSelected in
            self?.btnSelect.isSelected = isSelected
            self?.btnSelect.layer.removeAllAnimations()
            
            if isSelected,
               EPSPhotoUIConfiguration.default().animateSelectBtnWhenSelectInThumbVC {
                self?.btnSelect.layer.add(EPSAnimationUtils.springAnimation(), forKey: nil)
            }
            
            if isSelected {
                self?.fetchBigImage()
            } else {
                self?.progressView.isHidden = true
                self?.cancelFetchBigImage()
            }
        })
    }
    
    private func configureCell() {
        let config = EPSPhotoConfiguration.default()
        let uiConfig = EPSPhotoUIConfiguration.default()
        
        if uiConfig.cellCornerRadio > 0 {
            layer.cornerRadius = EPSPhotoUIConfiguration.default().cellCornerRadio
            layer.masksToBounds = true
        }
        
        if model.type == .video {
            bottomShadowView.isHidden = false
            videoTag.isHidden = false
            livePhotoTag.isHidden = true
            editImageTag.isHidden = true
            descLabel.text = model.duration
        } else if model.type == .gif {
            bottomShadowView.isHidden = !config.allowSelectGif
            videoTag.isHidden = true
            livePhotoTag.isHidden = true
            editImageTag.isHidden = true
            descLabel.text = "GIF"
        } else if model.type == .livePhoto {
            bottomShadowView.isHidden = !config.allowSelectLivePhoto
            videoTag.isHidden = true
            livePhotoTag.isHidden = false
            editImageTag.isHidden = true
            descLabel.text = "Live"
        } else {
            if let _ = model.editImage {
                bottomShadowView.isHidden = false
                videoTag.isHidden = true
                livePhotoTag.isHidden = true
                editImageTag.isHidden = false
                descLabel.text = ""
            } else {
                bottomShadowView.isHidden = true
            }
        }
        
        let showSelBtn: Bool
        if config.maxSelectCount > 1 {
            if !config.allowMixSelect {
                showSelBtn = model.type.rawValue < EPSPhotoModel.MediaType.video.rawValue
            } else {
                showSelBtn = true
            }
        } else {
            showSelBtn = config.showSelectBtnWhenSingleSelect
        }
        
        btnSelect.isHidden = !showSelBtn
        btnSelect.isUserInteractionEnabled = showSelBtn
        btnSelect.isSelected = model.isSelected
        
        if model.isSelected {
            fetchBigImage()
        } else {
            cancelFetchBigImage()
        }
        
        if let editImage = model.editImage {
            imageView.image = editImage
        } else {
            fetchSmallImage()
        }
    }
    
    private func fetchSmallImage() {
        let size: CGSize
        let maxSideLength = bounds.width * 2
        if model.whRatio > 1 {
            let w = maxSideLength * model.whRatio
            size = CGSize(width: w, height: maxSideLength)
        } else {
            let h = maxSideLength / model.whRatio
            size = CGSize(width: maxSideLength, height: h)
        }
        
        if smallImageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(smallImageRequestID)
        }
        
        imageIdentifier = model.ident
        imageView.image = nil
        smallImageRequestID = EPSPhotoManager.fetchImage(for: model.asset, size: size, completion: { [weak self] image, isDegraded in
            if self?.imageIdentifier == self?.model.ident {
                self?.imageView.image = image
            }
            if !isDegraded {
                self?.smallImageRequestID = PHInvalidImageRequestID
            }
        })
    }
    
    private func fetchBigImage() {
        cancelFetchBigImage()
        
        bigImageReqeustID = EPSPhotoManager.fetchOriginalImageData(for: model.asset, progress: { [weak self] progress, _, _, _ in
            if self?.model.isSelected == true {
                self?.progressView.isHidden = false
                self?.progressView.progress = max(0.1, progress)
                self?.imageView.alpha = 0.5
                if progress >= 1 {
                    self?.resetProgressViewStatus()
                }
            } else {
                self?.cancelFetchBigImage()
            }
        }, completion: { [weak self] _, _, _ in
            self?.resetProgressViewStatus()
        })
    }
    
    private func cancelFetchBigImage() {
        if bigImageReqeustID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(bigImageReqeustID)
        }
        resetProgressViewStatus()
    }
    
    private func resetProgressViewStatus() {
        progressView.isHidden = true
        imageView.alpha = 1
    }
}
