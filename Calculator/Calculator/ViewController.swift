//
//  ViewController.swift
//  Calculator
//
//  Created by Augusto on 12/16/16.
//  Copyright © 2016 Nihil Games. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var operationLabel: UILabel!
    
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
        updateOperationLabel()
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
            displayValue = 0.0
            updateOperationLabel()
        }
    }
    
    var savedProgram: AnyObject?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if let program = savedProgram {
            brain.program = program
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
    
}

