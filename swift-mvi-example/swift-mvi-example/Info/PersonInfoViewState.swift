//
//  PersonInfoViewState.swift
//  swift-mvi-example
//
//  Created by Wyeth Shamp on 8/30/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation
import Common

enum PersonInfoState {
    case idle
    case error(error: ClientError)
}

protocol PersonInfoViewStateProtocol {
    var personInfoState: PersonInfoState { get set }
    var personInfo: PersonInfoProtocol { get set }
}


struct PersonInfoViewState: PersonInfoViewStateProtocol {
    var personInfoState: PersonInfoState
    var personInfo: PersonInfoProtocol
    
    init(personInfoState: PersonInfoState,
         personInfo: PersonInfoProtocol) {
        self.personInfoState = personInfoState
        self.personInfo = personInfo
    }
}
