//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Augusto on 12/23/16.
//  Copyright © 2016 Nihil Games. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController {
    var brain: CalculatorBrain?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as? GraphingView {
            view.setup() as? GraphingView
        }
    }
    
}
