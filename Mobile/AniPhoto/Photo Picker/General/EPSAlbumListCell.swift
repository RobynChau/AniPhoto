//
//  EPSAlbumListCell.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/8/19.
//

import UIKit

class EPSAlbumListCell: UITableViewCell {
    private lazy var coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        if EPSPhotoUIConfiguration.default().cellCornerRadio > 0 {
            view.layer.masksToBounds = true
            view.layer.cornerRadius = EPSPhotoUIConfiguration.default().cellCornerRadio
        }
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .eps.font(ofSize: 17)
        label.textColor = .eps.albumListTitleColor
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .eps.font(ofSize: 16)
        label.textColor = .eps.albumListCountColor
        return label
    }()
    
    private var imageIdentifier: String?
    
    private var model: EPSAlbumListModel!
    
    private var style: AniPhotoStyle = .embedAlbumList
    
    private var indicator: UIImageView = {
        var image = UIImage.eps.getImage("zl_ablumList_arrow")
        if isRTL() {
            image = image?.imageFlippedForRightToLeftLayoutDirection()
        }
        
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var selectBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isUserInteractionEnabled = false
        btn.isHidden = true
        btn.setImage(.eps.getImage("zl_albumSelect"), for: .selected)
        return btn
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = contentView.eps.width
        let height = contentView.eps.height
        
        let coverImageW = height - 4
        let maxTitleW = width - coverImageW - 80
        
        var titleW: CGFloat = 0
        var countW: CGFloat = 0
        if let model = model {
            titleW = min(
                bounds.width / 3 * 2,
                model.title.eps.boundingRect(
                    font: .eps.font(ofSize: 17),
                    limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)
                ).width
            )
            titleW = min(titleW, maxTitleW)
            
            countW = ("(" + String(model.count) + ")").eps
                .boundingRect(
                    font: .eps.font(ofSize: 16),
                    limitSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30)
                ).width
        }
        
        if isRTL() {
            let imageViewX: CGFloat
            if style == .embedAlbumList {
                imageViewX = width - coverImageW
            } else {
                imageViewX = width - coverImageW - 12
            }
            
            coverImageView.frame = CGRect(x: imageViewX, y: 2, width: coverImageW, height: coverImageW)
            titleLabel.frame = CGRect(
                x: coverImageView.eps.left - titleW - 10,
                y: (height - 30) / 2,
                width: titleW,
                height: 30
            )
            
            countLabel.frame = CGRect(
                x: titleLabel.eps.left - countW - 10,
                y: (height - 30) / 2,
                width: countW,
                height: 30
            )
            selectBtn.frame = CGRect(x: 20, y: (height - 20) / 2, width: 20, height: 20)
            indicator.frame = CGRect(x: 20, y: (bounds.height - 15) / 2, width: 15, height: 15)
            return
        }
        
        let imageViewX: CGFloat
        if style == .embedAlbumList {
            imageViewX = 0
        } else {
            imageViewX = 12
        }
        
        coverImageView.frame = CGRect(x: imageViewX, y: 2, width: coverImageW, height: coverImageW)
        titleLabel.frame = CGRect(
            x: coverImageView.eps.right + 10,
            y: (bounds.height - 30) / 2,
            width: titleW,
            height: 30
        )
        countLabel.frame = CGRect(x: titleLabel.eps.right + 10, y: (height - 30) / 2, width: countW, height: 30)
        selectBtn.frame = CGRect(x: width - 20 - 20, y: (height - 20) / 2, width: 20, height: 20)
        indicator.frame = CGRect(x: width - 20 - 15, y: (height - 15) / 2, width: 15, height: 15)
    }
    
    func setupUI() {
        backgroundColor = .eps.albumListBgColor
        selectionStyle = .none
        accessoryType = .none
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(selectBtn)
        contentView.addSubview(indicator)
    }
    
    func configureCell(model: EPSAlbumListModel, style: AniPhotoStyle) {
        self.model = model
        self.style = style
        
        titleLabel.text = self.model.title
        countLabel.text = "(" + String(self.model.count) + ")"
        
        if style == .embedAlbumList {
            selectBtn.isHidden = false
            indicator.isHidden = true
        } else {
            indicator.isHidden = false
            selectBtn.isHidden = true
        }
        
        imageIdentifier = self.model.headImageAsset?.localIdentifier
        if let asset = self.model.headImageAsset {
            let w = bounds.height * 2.5
            EPSPhotoManager.fetchImage(for: asset, size: CGSize(width: w, height: w)) { [weak self] image, _ in
                if self?.imageIdentifier == self?.model.headImageAsset?.localIdentifier {
                    self?.coverImageView.image = image ?? .eps.getImage("zl_defaultphoto")
                }
            }
        }
    }
}
