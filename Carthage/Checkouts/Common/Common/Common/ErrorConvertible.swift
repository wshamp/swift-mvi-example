//
//  ErrorConvertible.swift
//  cryptominingtracker
//
//  Created by Wyeth Shamp on 2/10/18.
//  Copyright © 2018 wyethshamp All rights reserved.
//

import Foundation
import UIKit

public protocol ErrorConvertible : Error {
    func errorUserInfo() -> Dictionary<String, Any>
    func errorDomain() -> String
    func errorCode() -> Int
    func errorLocalizedDescription() -> String
    func wrappedError() -> ErrorConvertible?
}

public extension ErrorConvertible {
    public func errorUserInfo() -> Dictionary<String, Any> {
        return [NSLocalizedDescriptionKey: errorLocalizedDescription()]
    }
    
    public func showAlert(with message: String? = nil) {
        DispatchQueue.main.async {
            let alertController =  UIAlertController(title: "Error", message: message ?? self.errorLocalizedDescription(), preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "Continue", style: .default, handler: nil)
            alertController.addAction(continueAction)
            alertController.show()
        }
    }
}

extension NSError : ErrorConvertible {
    public func errorUserInfo() -> Dictionary<String, Any> {
        return self.userInfo
    }
    
    public func errorDomain() -> String {
        return self.domain
    }
    
    public func errorCode() -> Int {
        return self.code
    }
    
    public func errorLocalizedDescription() -> String {
        return self.localizedDescription
    }
    
    public func wrappedError() -> ErrorConvertible? {
        return nil
    }
    
}
