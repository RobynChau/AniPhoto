//
//  EPSAddPhotoCell.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/11/3.
//

import UIKit
import Foundation

class EPSAddPhotoCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: .eps.getImage("zl_addPhoto"))
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    deinit {
        eps_debugPrint("EPSAddPhotoCell deinit")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width / 3, height: bounds.width / 3)
        imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    func setupUI() {
        if EPSPhotoUIConfiguration.default().cellCornerRadio > 0 {
            layer.masksToBounds = true
            layer.cornerRadius = EPSPhotoUIConfiguration.default().cellCornerRadio
        }
        
        backgroundColor = .eps.cameraCellBgColor
        contentView.addSubview(imageView)
    }
}
