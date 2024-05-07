//
//  EPSPhotoPreviewAnimatedTransition.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/9/3.
//

import UIKit

class EPSPhotoPreviewAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
}
