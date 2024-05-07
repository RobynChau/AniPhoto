//
//  UIScrollView+AniPhoto.swift
//  AniPhoto
//
//  Created by PhatCH on 2023/10/8.
//

import UIKit

extension AniPhotoWrapper where Base: UIScrollView {
    var contentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return base.adjustedContentInset
        } else {
            return base.contentInset
        }
    }
    
    func scrollToTop(animated: Bool = true) {
        base.setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: animated)
    }
    
    func scrollToBottom(animated: Bool = true) {
        let contentSizeH = base.contentSize.height
        let insetBottom = contentInset.bottom
        let offsetY = contentSizeH + insetBottom - base.eps.height
        base.setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)
    }
}
