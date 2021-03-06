//
//  ViewController.swift
//  Calculator
//
//  Created by Augusto on 12/16/16.
//  Copyright © 2016 Nihil Games. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var graphButton: UIButton!
    
    fileprivate var brain = CalculatorBrain()
    
    fileprivate var userIsInTheMiddleOfTyping = false
    
    fileprivate let displayFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        return formatter
    }()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            if digit != "." || !display.text!.contains(".") {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
            }
        }
        userIsInTheMiddleOfTyping = true
    }
    
    fileprivate var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            if let value = newValue {
                display.text = displayFormatter.string(from: value)
            } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.set(operand: displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathemathicalSymbol = sender.currentTitle {
            brain.perform(operation: mathemathicalSymbol)
        }
        
        displayValue = brain.result
        
        if brain.errorOccurred {
            raiseError()
        }
        updateOperationLabel()
        configureGraphButton()
        
        UserDefaults.standard.set(brain.program, forKey: "calculator program")
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func configureGraphButton () {
        if brain.isPartialResult {
            graphButton.isEnabled = false
            graphButton.alpha = 0.5
        } else {
            graphButton.isEnabled = true
            graphButton.alpha = 1.0
        }
    }
    
    fileprivate func raiseError() {
        let alert = UIAlertController(title: "Math error",
                                      message: "There was a problem performing the operation",
                                      preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
        clear()
    }
    
    @IBAction func clear() {
        brain = CalculatorBrain()
        display.text = "0"
        userIsInTheMiddleOfTyping =  false
        updateOperationLabel()
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTyping {
            if display.text!.characters.count == 1 {
                display.text = "0"
                userIsInTheMiddleOfTyping = false;
            } else if display.text!.characters.count > 1 {
                display.text = display.text!.substring(to: display.text!.index(before: display.text!.endIndex))
            }
        } else {
            brain.removeLastOp()
            displayValue = brain.result
            updateOperationLabel()
        }
    }
        
    func updateOperationLabel() {
        if !brain.description.isEmpty {
            if brain.isPartialResult {
                operationLabel.text = brain.description + "..."
            } else {
                operationLabel.text = brain.description + "="
            }
        } else {
            operationLabel.text = "0"
        }
    }
    
    @IBAction func saveVariable() {
        brain.variableValues["M"] = displayValue ?? 0.0
        displayValue = brain.result
        updateOperationLabel()
        userIsInTheMiddleOfTyping = false
    }
    
    
    @IBAction func getVariable() {
        brain.set(operand: "M")
        displayValue = brain.result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        
        if let navigationVC = destinationVC as? UINavigationController {
            destinationVC = navigationVC.visibleViewController ?? destinationVC
        }
        
        if let graphingVC = destinationVC as? GraphingViewController {
            if segue.identifier == "show graph" {
                graphingVC.program = brain.program
            }
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "show graph" {
            return !brain.isPartialResult
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Calculator"
        
        if let program = UserDefaults.standard.value(forKey: "calculator program") as AnyObject? {
            brain.program = program
            displayValue = brain.result
            updateOperationLabel()
            configureGraphButton()
        }
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if UserDefaults.standard.value(forKey: GraphingViewController.keyForUserDefaults) == nil { // does this violate mvc?
            return true
        } else {
            return false
        }
    }

    
}

