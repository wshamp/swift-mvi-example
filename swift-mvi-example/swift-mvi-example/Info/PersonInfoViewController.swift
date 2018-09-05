//
//  PersonInfoViewController.swift
//  swift-mvi-example
//
//  Created by Wyeth Shamp on 8/30/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveSwiftCommon

class PersonInfoViewController: UIViewController {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    var personInfoInteractor: PersonInfoInteractorProtocol!
    var personInfoViewModel: PersonInfoViewModelProtocol!

    lazy var lifetimeManager: LifetimeManager = {
        let lifetimeManager = LifetimeManager { [weak self] lifetime in
            self?.setupBindings()
        }
        return lifetimeManager
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lifetimeManager.updateLifetime()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifetimeManager.invalidateLifetime()
    }
    
    func setupBindings() {
        guard let lifetime = lifetimeManager.lifetime else {
            return
        }
        
        personInfoViewModel.personInfoViewState.producer.startWithValuesOnMainQueue(during: lifetime) { [weak self] value in
            switch value.personInfoState {
            case .error(let error):
                self?.handleError(error: error)
            case .idle:
                self?.update(for: value.personInfo)
            }
        }
        
    }
    
    func update(for personInfo: PersonInfoProtocol) {
        self.firstNameLabel.text = personInfo.firstName
        self.lastNameLabel.text = personInfo.lastName
    }

    @IBAction func randomFirstNameButtonTouched(_ sender: Any) {
        personInfoInteractor.personInfoEventObserver.send(value: .firstNameChanged(firstName: "1"))
    }
    @IBAction func randomLastNameButtonTouched(_ sender: Any) {
        personInfoInteractor.personInfoEventObserver.send(value: .lastNameChanged(lastName: "1"))
    }
    
    @IBAction func createErrorButtonTouched(_ sender: Any) {
        personInfoInteractor.personInfoEventObserver.send(value: .error(error: .testError(message: "test")))
    }
    
}
