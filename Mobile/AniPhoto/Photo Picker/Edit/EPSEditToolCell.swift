//
//  EPSEditToolCell.swift
//  AniPhoto
//
//  Created by PhatCH on 2021/12/16.
//

import UIKit

// MARK: Edit tool cell
@objcMembers
class EPSEditToolCell: UICollectionViewCell {
    var toolType: EPSImageEditorConfiguration.EditTool = .draw {
        didSet {
            switch toolType {
            case .draw:
                icon.image = .eps.getImage("zl_drawLine")
                icon.highlightedImage = .eps.getImage("zl_drawLine_selected")
            case .clip:
                icon.image = .eps.getImage("zl_clip")
                icon.highlightedImage = .eps.getImage("zl_clip")
            case .imageSticker:
                icon.image = .eps.getImage("zl_imageSticker")
                icon.highlightedImage = .eps.getImage("zl_imageSticker")
            case .textSticker:
                icon.image = .eps.getImage("zl_textSticker")
                icon.highlightedImage = .eps.getImage("zl_textSticker")
            case .mosaic:
                icon.image = .eps.getImage("zl_mosaic")
                icon.highlightedImage = .eps.getImage("zl_mosaic_selected")
            case .filter:
                icon.image = .eps.getImage("zl_filter")
                icon.highlightedImage = .eps.getImage("zl_filter_selected")
            case .adjust:
                icon.image = .eps.getImage("zl_adjust")
                icon.highlightedImage = .eps.getImage("zl_adjust_selected")
            }
            if let color = UIColor.eps.imageEditorToolIconTintColor {
                icon.highlightedImage = icon.highlightedImage?
                    .eps.fillColor(color)
            }
        }
    }
    
    lazy var icon = UIImageView(frame: contentView.bounds)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(icon)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: draw color cell

class ZLDrawColorCell: UICollectionViewCell {
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return view
    }()
    
    lazy var bgWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        return view
    }()
    
    var color: UIColor = .clear {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bgWhiteView)
        contentView.addSubview(colorView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorView.center = contentView.center
        bgWhiteView.center = contentView.center
    }
}

// MARK: filter cell
@objcMembers
public class EPSFilterImageCell: UICollectionViewCell {
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: bounds.height - 20, width: bounds.width, height: 20)
        label.font = .eps.font(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(imageView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: adjust tool cell

class EPSAdjustToolCell: UICollectionViewCell {
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: bounds.height - 30, width: bounds.width, height: 30)
        label.font = .eps.font(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        label.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.frame = CGRect(x: (bounds.width - 30) / 2, y: 0, width: 30, height: 30)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    var adjustTool: EPSImageEditorConfiguration.AdjustTool = .brightness {
        didSet {
            switch adjustTool {
            case .brightness:
                imageView.image = .eps.getImage("zl_brightness")
                imageView.highlightedImage = .eps.getImage("zl_brightness_selected")
                nameLabel.text = localLanguageTextValue(.brightness)
            case .contrast:
                imageView.image = .eps.getImage("zl_contrast")
                imageView.highlightedImage = .eps.getImage("zl_contrast_selected")
                nameLabel.text = localLanguageTextValue(.contrast)
            case .saturation:
                imageView.image = .eps.getImage("zl_saturation")
                imageView.highlightedImage = .eps.getImage("zl_saturation_selected")
                nameLabel.text = localLanguageTextValue(.saturation)
            }
            if let color = UIColor.eps.imageEditorToolIconTintColor {
                imageView.highlightedImage = imageView.highlightedImage?
                    .eps.fillColor(color)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(imageView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
