//
//  EPSAniGANTransition.swift
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

import Foundation

@objcMembers
public class EPSAniGANPresentEditorTransition : NSObject, UIViewControllerAnimatedTransitioning {
    var animator: UIViewImplicitlyAnimating?

    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.15
    }
    
    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let animator = self.interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }

    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if self.animator != nil {
            return self.animator!
        }

        let container = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)!

        let fromViewInitialFrame = transitionContext.initialFrame(for: fromVC)
        var fromViewFinalFrame = fromViewInitialFrame
        fromViewFinalFrame.origin.x = -fromViewFinalFrame.width

        let fromView = fromVC.view!
        let toView = transitionContext.view(forKey: .to)!

        var toViewInitialFrame = fromViewInitialFrame
        toViewInitialFrame.origin.x = toView.frame.size.width

        toView.frame = toViewInitialFrame
        container.addSubview(toView)

        let animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), curve: .easeInOut) {

            toView.frame = fromViewInitialFrame
            fromView.frame = fromViewFinalFrame
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(true)
        }

        self.animator = animator
        return animator
    }

    public func animationEnded(_ transitionCompleted: Bool) {
        self.animator = nil
    }
}

@objcMembers
public class EPSAniGANDismissEditorTransition : NSObject, UIViewControllerAnimatedTransitioning {
    var animator: UIViewImplicitlyAnimating?

    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.15
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let animator = self.interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }

    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if self.animator != nil {
            return self.animator!
        }

        let fromVC = transitionContext.viewController(forKey: .from)!

        var fromViewInitialFrame = transitionContext.initialFrame(for: fromVC)
        fromViewInitialFrame.origin.x = 0
        var fromViewFinalFrame = fromViewInitialFrame
        fromViewFinalFrame.origin.x = fromViewFinalFrame.width

        let fromView = fromVC.view!
        let toView = transitionContext.viewController(forKey: .to)!.view!

        var toViewInitialFrame = fromViewInitialFrame
        toViewInitialFrame.origin.x = -toView.frame.size.width

        toView.frame = toViewInitialFrame

        let animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), curve: .easeInOut) {

            toView.frame = fromViewInitialFrame
            fromView.frame = fromViewFinalFrame
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(true)
        }

        self.animator = animator
        return animator
    }

    public func animationEnded(_ transitionCompleted: Bool) {
        self.animator = nil
    }
}
