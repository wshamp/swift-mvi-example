//
//  PresentationNavigationController.swift
//
//  Created by Wyeth Shamp on 5/12/16.
//  Copyright © 2018 wyethshamp All rights reserved.
//

import Foundation
import UIKit

open class PresentationNavigationController: UINavigationController {
    
    @IBInspectable open var shouldDismissOnBackgroundTouch:Bool = true
    @IBInspectable open var viewHeight:NSNumber?
    @IBInspectable open var viewWidth:NSNumber?
    @IBInspectable open var offset:NSNumber?
    @IBInspectable open var direction:String = "Bottom" {
        didSet {
            if let offset = offset {
                self.modalDirection = PresentationControllerModalDirection(direction: direction, offset: CGFloat(truncating: offset))
            } else {
                self.modalDirection = PresentationControllerModalDirection(direction: direction, offset: 0)
            }
            
        }
    }
    var animationViewController:PresentationAnimationController?
    var modalDirection: PresentationControllerModalDirection = .fromBottom(offset: 0)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
}

extension PresentationNavigationController : UIViewControllerTransitioningDelegate {
    open func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
                                 source: UIViewController) -> UIPresentationController? {
        if presented == self {
            return PresentationController(
                presentedViewController: presented,
                presentingViewController: presenting,
                presentedViewHeight: viewHeight == nil ? nil : CGFloat(truncating: viewHeight!),
                presentedViewWidth: viewWidth == nil ? nil : CGFloat(truncating: viewWidth!),
                modalDirection: modalDirection,
                shouldDismissOnBackgroundTouch: shouldDismissOnBackgroundTouch)
        }
        
        return nil
    }
    
    open func animationController(
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
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            self.animationViewController?.isPresenting = false
            return self.animationViewController
        }
        else {
            return nil
        }
    }
}
