//
//  ErrorDispatcher.swift
//  cryptominingtracker
//
//  Created by Wyeth Shamp on 2/10/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation
import UIKit

public protocol ErrorDispatcher {
    func dispatchError(error: ErrorConvertible)
}

public struct AlertErrorDispatcher: ErrorDispatcher {
    public init() {}
    public func dispatchError(error: ErrorConvertible) {
        error.showAlert()
    }
}

var AssociatedObjectHandle: UInt8 = 0
public extension UIAlertController {
    var alertWindow:UIWindow {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! UIWindow
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func show() {
        present(animated:true, completion: nil)
    }
    
    public func present(animated: Bool, completion:(() -> Void)?) {
        if let window = UIApplication.shared.keyWindow {
            self.alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
            self.alertWindow.rootViewController = UIViewController()
            self.alertWindow.windowLevel = window.windowLevel + 1
            self.alertWindow.makeKeyAndVisible()
            self.alertWindow.rootViewController?.present(self, animated: animated, completion: completion)
        } else {
            fatalError("No Window")
        }
    }
}
