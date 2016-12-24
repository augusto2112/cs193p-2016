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

    override func viewDidLoad() {
        super.viewDidLoad()
        if program != nil {
            brain.program = program!
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
