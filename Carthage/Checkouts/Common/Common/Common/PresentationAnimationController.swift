//
//  PresentationAnimationController.swift
//
//  Created by Wyeth Shamp on 5/12/16.
//  Copyright © 2018 wyethshamp All rights reserved.
//

import Foundation
import UIKit

class PresentationAnimationController : NSObject {
    var isPresenting :Bool
    let duration :TimeInterval = 0.5
    let modalDirection : PresentationControllerModalDirection
    
    init(isPresenting: Bool, modalDirection: PresentationControllerModalDirection) {
        self.isPresenting = isPresenting
        self.modalDirection = modalDirection
        super.init()
    }
    func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                return
        }
        let containerView = transitionContext.containerView
        let originalFrame = transitionContext.finalFrame(for: presentedController)
        presentedControllerView.frame = originalFrame
        switch modalDirection {
        case .fromMiddle:
            presentedControllerView.alpha = 0.0
            presentedControllerView.frame.origin.y = (containerView.bounds.size.height - presentedControllerView.frame.size.height)/2
            presentedControllerView.frame.origin.x = (containerView.bounds.size.width - presentedControllerView.frame.size.width)/2
        case .fromTop(let offset):
            if offset == 0 {
                presentedControllerView.frame.origin.y = presentedControllerView.frame.size.height * -1
            } else {
                presentedControllerView.frame.origin.y = offset
                presentedControllerView.frame.size.height = 0
            }
        case .fromBottom(let offset):
            if offset == 0 {
                presentedControllerView.frame.origin.y = containerView.bounds.size.height
            } else {
                presentedControllerView.frame.origin.y = containerView.bounds.size.height - offset
                presentedControllerView.frame.size.height = 0
            }
        case .fromRight(let offset):
            if offset == 0 {
                presentedControllerView.frame.origin.x = containerView.bounds.size.width
            } else {
                presentedControllerView.frame.origin.x = containerView.bounds.size.width - offset
                presentedControllerView.frame.size.width = 0
            }
        case .fromLeft(let offset):
            if offset == 0 {
                presentedControllerView.frame.origin.x = containerView.bounds.size.width * -1
            } else {
                presentedControllerView.frame.origin.x = offset
                presentedControllerView.frame.size.width = 0
            }
            
            
            presentedControllerView.frame.origin.x = (containerView.bounds.size.width * -1) + offset
        }
        containerView.addSubview(presentedControllerView)
        
        UIView.animate(
            withDuration: self.duration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: .allowUserInteraction,
            animations: { [unowned self] in
                switch self.modalDirection {
                case .fromMiddle:
                    presentedControllerView.frame.origin.y = (containerView.bounds.size.height - presentedControllerView.frame.size.height)/2
                    presentedControllerView.frame.origin.x = (containerView.bounds.size.width - presentedControllerView.frame.size.width)/2
                    presentedControllerView.alpha = 1.0
                case .fromTop(let offset):
                    presentedControllerView.frame.origin.y = offset
                    presentedControllerView.frame.size.height = originalFrame.size.height
                case .fromBottom(let offset):
                    presentedControllerView.frame.origin.y = containerView.bounds.size.height - (presentedControllerView.frame.size.height + offset)
                    presentedControllerView.frame.size.height = originalFrame.size.height
                case .fromRight(let offset):
                    presentedControllerView.frame.origin.x = containerView.bounds.size.width - (presentedControllerView.frame.size.width + offset)
                    presentedControllerView.frame.size.width = originalFrame.size.width
                case .fromLeft(let offset):
                    presentedControllerView.frame.origin.x = 0 + offset
                    presentedControllerView.frame.size.width = originalFrame.size.width
                }
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
    
    func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
                return
        }
        let containerView = transitionContext.containerView
        UIView.animate(
            withDuration: self.duration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: .allowUserInteraction,
            animations: { [unowned self] in
                switch self.modalDirection {
                case .fromMiddle:
                    presentedControllerView.alpha = 0.0
                case .fromTop(let offset):
                    if offset == 0 {
                        presentedControllerView.frame.origin.y = presentedControllerView.frame.size.height * -1
                    } else {
                        presentedControllerView.frame.size.height = 0
                    }
                    
                case .fromBottom(let offset):
                    if offset == 0 {
                        presentedControllerView.frame.origin.y = containerView.bounds.size.height
                    } else {
                        presentedControllerView.frame.size.height = 0
                    }
                case .fromRight(let offset):
                    if offset == 0 {
                        presentedControllerView.frame.origin.x = containerView.bounds.size.width
                    } else {
                        presentedControllerView.frame.size.width = 0
                    }
                case .fromLeft(let offset):
                    if offset == 0 {
                        presentedControllerView.frame.origin.x = presentedControllerView.frame.size.width * -1
                    } else {
                        presentedControllerView.frame.size.width = 0
                    }
                }
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
}

extension PresentationAnimationController : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        } else {
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
}
