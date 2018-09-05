//
//  ViewController.swift
//  swift-mvi-example
//
//  Created by Wyeth Shamp on 8/30/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

protocol ClientErrorHandler {
    func handleError(error: ClientError)
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Invalid identifier")
        }
        
        switch identifier {
        case "ShowPerson":
            guard let personInfoViewController = segue.destination as? PersonInfoViewController else {
                fatalError("Invalid ViewController")
            }
            let (personInfoEventSignal, personInfoEventObserver) = Signal<PersonInfoEvent, NoError>.pipe()
            let personInfoInteractor = PersonInfoInteractor(personInfoEventObserver: personInfoEventObserver)
            let personInfoViewModel = PersonInfoViewModel(personInfoEventSignal: personInfoEventSignal,
                                                          initialPersonInfoViewState: PersonInfoViewState(personInfoState: .idle,
                                                                                                          personInfo: PersonInfo(firstName: "Initial First Name", lastName: "Initial Last Name")))
            
            personInfoViewController.personInfoInteractor = personInfoInteractor
            personInfoViewController.personInfoViewModel = personInfoViewModel
        default:
            break
        }
    }
    
    
}

extension UIViewController : ClientErrorHandler {
    func handleError(error: ClientError) {
        let alertController = UIAlertController(title: "Error", message: error.errorLocalizedDescription(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
