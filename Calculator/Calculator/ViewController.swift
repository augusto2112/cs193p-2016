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
    
    var userIsInTheMiddleOfTyping = false
    
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
        brain.numberTyped = true
    }
    
    fileprivate var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.set(operand: displayValue)
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
}

