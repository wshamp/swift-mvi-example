//
//  PersonInfoInteractor.swift
//  swift-mvi-example
//
//  Created by Wyeth Shamp on 8/30/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation
import ReactiveSwift
import Common
import Result

enum PersonInfoEvent {
    case firstNameChanged(firstName: String)
    case lastNameChanged(lastName: String)
    case error(error: ClientError)
}

protocol PersonInfoInteractorProtocol {
    var personInfoEventObserver: Signal<PersonInfoEvent, NoError>.Observer { get }
}

struct PersonInfoInteractor: PersonInfoInteractorProtocol {
    let personInfoEventObserver: Signal<PersonInfoEvent, NoError>.Observer
    
    init(personInfoEventObserver: Signal<PersonInfoEvent, NoError>.Observer) {
        self.personInfoEventObserver = personInfoEventObserver
    }

}
