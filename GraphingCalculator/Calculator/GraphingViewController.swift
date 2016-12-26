//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Augusto on 12/23/16.
//  Copyright © 2016 Nihil Games. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController, GraphingViewDelegate {
    fileprivate let brain = CalculatorBrain()
    var program: AnyObject?
    static let keyForUserDefaults = "graphing program"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard

        if program != nil {
            brain.program = program!
            self.navigationItem.title = brain.description
            defaults.set(program, forKey: GraphingViewController.keyForUserDefaults)
            defaults.synchronize()
        } else if let storedProgram = defaults.value(forKey: GraphingViewController.keyForUserDefaults) as AnyObject? {
            brain.program = storedProgram
            self.navigationItem.title = brain.description
        }

        if let view = self.view as? GraphingView {
            view.setup()
            view.delegate = self
        }
    }
    

    internal func needYAt(x: CGFloat) -> CGFloat {
        brain.variableValues["M"] = Double(x)
        return CGFloat(brain.result)
    }
    

}
