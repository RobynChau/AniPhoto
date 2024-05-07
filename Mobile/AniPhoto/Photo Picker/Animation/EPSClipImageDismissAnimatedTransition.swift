//
//  EPSClipImageDismissAnimatedTransition.swift
//  AniPhoto
//
//  Created by PhatCH on 2020/9/8.
//

import UIKit

class EPSClipImageDismissAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? EPSClipImageViewController, let toVC = transitionContext.viewController(forKey: .to) as? EPSImageEditorViewController else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        let imageView = UIImageView(frame: fromVC.dismissAnimateFromRect)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = fromVC.dismissAnimateImage
        containerView.addSubview(imageView)
        
        UIView.animate(withDuration: 0.3, animations: {
            imageView.frame = toVC.originalFrame
        }) { _ in
            toVC.finishClipDismissAnimate()
            imageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
