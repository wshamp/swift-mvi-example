//
//  ClientError.swift
//  swift-mvi-example
//
//  Created by Wyeth Shamp on 8/31/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation
import Common

enum ClientError : ErrorConvertible, Equatable {
    case deallocationError(message: String)
    case testError(message: String)
    
    
    func errorDomain() -> String {
        return "ClientDomain"
    }
    
    func errorCode() -> Int {
        switch self {
        case .deallocationError:
            return 1
        case .testError:
            return 2
        }
    }
    
    func errorLocalizedDescription() -> String {
        switch self {
        case .deallocationError(let message),
             .testError(let message):
            return "Domain: \(self.errorDomain()) Code: \(self.errorCode()) Description: \(message)"
        }
    }
    
    func wrappedError() -> ErrorConvertible? {
        return nil
    }
}


func ==(lhs: ClientError, rhs: ClientError) -> Bool {
    return lhs.errorLocalizedDescription() == rhs.errorLocalizedDescription()
}
