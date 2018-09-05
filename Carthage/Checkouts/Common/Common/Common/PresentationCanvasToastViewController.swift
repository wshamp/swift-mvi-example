//
//  PresentationCanvasToastViewController.swift
//  WDCommon
//
//  Created by Wyeth Shamp on 7/5/17.
//  Copyright © 2018 wyethshamp All rights reserved.
//

import Foundation
import UIKit

public class PresentationCanvasToastViewController: UIViewController {
    public var viewHeight: CGFloat = 72.0
    public var automaticallyDismisses: Bool = true
    public var automaticallyDismissAfter: TimeInterval = 1.3
    public var bottomMargin: CGFloat = 8.0
    public var leftMargin: CGFloat = 8.0
    public var rightMargin: CGFloat = 8.0
    public private(set) var toastView: PresentationCanvasToastView?
    
    var animationViewController:PresentationAnimationController?
    var modalDirection: PresentationControllerModalDirection = .fromBottom(offset: 0)
    
    public init(text: String, accessoryView: UIView?) {
        super.init(nibName: nil, bundle: nil)
        commonInit(text: text, accessoryView: accessoryView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(text: "", accessoryView: nil)
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit(text: "", accessoryView: nil)
    }
    
    func commonInit(text: String, accessoryView: UIView?) {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
        let toastViewFrame = CGRect(x: leftMargin,
                                    y: CGFloat(0),
                                    width: self.view.frame.width - leftMargin - rightMargin,
                                    height: viewHeight - bottomMargin)
        toastView = PresentationCanvasToastView(frame: toastViewFrame, text: text, accessoryView: accessoryView)
        view.addSubview(toastView!)
    }
}

extension PresentationCanvasToastViewController : UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController) -> UIPresentationController? {
        if presented == self {
            if automaticallyDismisses {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + automaticallyDismissAfter) { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
            return PresentationController(
                presentedViewController: presented,
                presentingViewController: presenting,
                presentedViewHeight: viewHeight,
                // I suspect that this parameter doesn't actually affect anything...
                presentedViewWidth: CGFloat(0),
                modalDirection: .fromBottom(offset: 0),
                shouldDismissOnBackgroundTouch: false,
                shouldDisplayDimmingView: false)
        }
        
        return nil
    }
    
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            self.animationViewController = PresentationAnimationController(isPresenting: true, modalDirection: modalDirection)
            return self.animationViewController
        }
        else {
            return nil
        }
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            self.animationViewController?.isPresenting = false
            return self.animationViewController
        }
        else {
            return nil
        }
    }
}
