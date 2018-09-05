//
//  PresentationController.swift
//
//  Created by Wyeth Shamp on 5/12/16.
//  Copyright © 2018 wyethshamp All rights reserved.
//

import Foundation
import UIKit

enum PresentationControllerModalDirection {
    case fromTop(offset: CGFloat)
    case fromBottom(offset: CGFloat)
    case fromRight(offset: CGFloat)
    case fromLeft(offset: CGFloat)
    case fromMiddle
    
    init(direction: String, offset: CGFloat) {
        switch direction {
        case "Top":
            self = PresentationControllerModalDirection.fromTop(offset: offset)
        case "Left":
            self = PresentationControllerModalDirection.fromLeft(offset: offset)
        case "Right":
            self = PresentationControllerModalDirection.fromRight(offset: offset)
        case "Middle":
            self = PresentationControllerModalDirection.fromMiddle
        default:
            self = PresentationControllerModalDirection.fromBottom(offset: offset)
        }
    }
}

class PresentationController: UIPresentationController {
    
    let presentedViewHeight: CGFloat?
    let presentedViewWidth: CGFloat?
    
    let modalDirection: PresentationControllerModalDirection
    let shouldDismissOnBackgroundTouch: Bool
    let shouldDisplayDimmingView: Bool
    lazy var dimmingViewGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PresentationController.dimmingViewTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }()
    
    lazy var contentViewGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PresentationController.dimmingViewTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }()
    
    lazy var dimmingView: UIView? = {
        guard let containerView = self.containerView else {
            fatalError("Should not be called before container view is set")
        }
        if !self.shouldDisplayDimmingView {
            return nil
        }
        let view = UIView(frame: containerView.bounds)
        switch self.modalDirection {
        case .fromTop(let offset):
            view.frame.origin.y += offset
        case .fromBottom(let offset):
            view.frame.origin.y -= offset
        case .fromRight(let offset):
            view.frame.origin.x += offset
        case .fromLeft(let offset):
            view.frame.origin.x -= offset
        default:
            break
            
        }
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        view.isUserInteractionEnabled = true
        view.accessibilityIdentifier = "Dimming View"
        view.addGestureRecognizer(self.dimmingViewGestureRecognizer)
        view.alpha = 0.0
        return view
    }()
    
    lazy var offsetRemainderView: UIView? = {
        guard let containerView = self.containerView else {
            fatalError("Should not be called before container view is set")
        }
        let view = UIView(frame: containerView.bounds)
        switch self.modalDirection {
        case .fromTop(let offset):
            view.frame.size.height = offset
        case .fromBottom(let offset):
            view.frame.origin.y = view.frame.size.height - offset
            view.frame.size.height = offset
        case .fromRight(let offset):
            view.frame.origin.x = view.frame.size.width - offset
            view.frame.size.width = offset
        case .fromLeft(let offset):
            view.frame.size.width = offset
        default:
            return nil
        }
        
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = true
        view.accessibilityIdentifier = "Remainder View"
        view.addGestureRecognizer(self.contentViewGestureRecognizer)
        return view
    }()
    
    init(
        presentedViewController: UIViewController,
        presentingViewController: UIViewController?,
        presentedViewHeight: CGFloat? = nil,
        presentedViewWidth: CGFloat? = nil,
        modalDirection:PresentationControllerModalDirection,
        shouldDismissOnBackgroundTouch: Bool = true,
        shouldDisplayDimmingView: Bool = true) {
        
        var safeAreaExtra:CGFloat = 0.0
        let safeAreaInsets = presentedViewController.view.safeAreaInsets
        switch modalDirection {
        case .fromTop:
            safeAreaExtra = safeAreaInsets.top
        case .fromBottom:
            safeAreaExtra = safeAreaInsets.bottom
        default:
            break
        }
        if let presentedViewHeight = presentedViewHeight {
            self.presentedViewHeight = presentedViewHeight + safeAreaExtra
        } else {
            self.presentedViewHeight = nil
        }
        self.presentedViewWidth = presentedViewWidth
        self.modalDirection = modalDirection
        self.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch
        self.shouldDisplayDimmingView = shouldDisplayDimmingView
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    @objc func dimmingViewTapped() {
        if shouldDismissOnBackgroundTouch {
            self.presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView, let presentedView = presentedView else {
            return
        }
        containerView.isUserInteractionEnabled = shouldDisplayDimmingView
        if shouldDisplayDimmingView, let dimmingView = dimmingView {
            containerView.addSubview(dimmingView)
        }
        if let remainderView = offsetRemainderView {
            containerView.addSubview(remainderView)
        }
        containerView.addSubview(presentedView)
        
        if shouldDisplayDimmingView, let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView?.alpha = 1.0
                }, completion:nil)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool)  {
        if !completed {
            self.dimmingView?.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin()  {
        if shouldDisplayDimmingView, let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView?.alpha  = 0.0
                }, completion:nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.dimmingView?.removeFromSuperview()
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect()
        }
        let frame = containerView.bounds;
        switch self.modalDirection {
        case .fromMiddle:
            guard let presentedViewWidth = self.presentedViewWidth, let presentedViewHeight = self.presentedViewHeight else {
                return frame
            }
            return CGRect(x: (frame.width - presentedViewWidth)/2, y: (frame.height - presentedViewHeight)/2, width: presentedViewWidth, height: presentedViewHeight)
        case .fromBottom(let offset):
            guard let presentedViewHeight = self.presentedViewHeight else {
                return frame
            }
            return CGRect(x: frame.origin.x, y: frame.height - (presentedViewHeight + offset), width: frame.width, height: presentedViewHeight)
        case .fromTop(let offset):
            guard let presentedViewHeight = self.presentedViewHeight else {
                return frame
            }
            var navBarHeight:CGFloat = 0
            if let navController = self.presentingViewController as? UINavigationController {
                navBarHeight = navController.navigationBar.frame.height + navController.navigationBar.frame.origin.y
            } else if let navController = self.presentingViewController.navigationController {
                navBarHeight = navController.navigationBar.frame.height + navController.navigationBar.frame.origin.y
            }
            return CGRect(x: frame.origin.x, y: (frame.origin.y + offset), width: frame.width, height: navBarHeight + presentedViewHeight)
        case .fromRight(let offset):
            guard let presentedViewWidth = self.presentedViewWidth else {
                return frame
            }
            return CGRect(x: frame.width - (presentedViewWidth + offset), y: frame.origin.y, width: presentedViewWidth, height: frame.height)
        case .fromLeft(let offset):
            guard let presentedViewWidth = self.presentedViewWidth else {
                return frame
            }
            return CGRect(x: (frame.origin.x + offset), y: frame.origin.y, width: presentedViewWidth, height: frame.height)
        }
        
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let containerView = containerView else {
            return
        }
        
        coordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.dimmingView?.frame = containerView.bounds
            self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
            }, completion:nil)
    }
    
}
