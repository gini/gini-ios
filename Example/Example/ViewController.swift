//
//  ViewController.swift
//  Example
//
//  Created by Enrique del Pozo Gómez on 3/4/19.
//  Copyright © 2019 Gini GmbH. All rights reserved.
//

import UIKit
import Gini

class ViewController: UIViewController {
    let test = TestPublic()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        test.accessToken()
        //        test.loginAsUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        test.load()

    }
    
    
}


