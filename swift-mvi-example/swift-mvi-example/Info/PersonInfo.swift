//
//  PersonInfo.swift
//  swift-mvi-example
//
//  Created by Wyeth Shamp on 8/30/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation

protocol PersonInfoProtocol {
    var firstName: String { get set }
    var lastName: String { get set }
}

struct PersonInfo: PersonInfoProtocol {
    var firstName: String
    var lastName: String
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
