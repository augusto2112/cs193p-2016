//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Augusto on 12/16/16.
//  Copyright © 2016 Nihil Games. All rights reserved.
//

import Foundation


fileprivate struct PendingBinaryOperationInfo {
    var binaryFunction: (Double, Double) -> Double
    var firstOperand: Double
}

fileprivate enum Operation {
    case constant(Double)
    case independentOperation(() -> Double)
    case unaryOperation((Double) -> Double)
    case binaryOperation((Double, Double) -> Double)
    case equals
}

fileprivate let operations: Dictionary<String, Operation> = [
    "π": Operation.constant(M_PI),
    "e": Operation.constant(M_E),
    "🎲": Operation.independentOperation({return Double(arc4random()) / Double(UInt32.max)}),
    "√": Operation.unaryOperation(sqrt),
    "cos": Operation.unaryOperation(cos),
    "sin": Operation.unaryOperation(sin),
    "tan": Operation.unaryOperation(tan),
    "±": Operation.unaryOperation({-$0}),
    "+": Operation.binaryOperation({ $0 + $1}),
    "-": Operation.binaryOperation({ $0 - $1}),
    "×": Operation.binaryOperation({ $0 * $1}),
    "÷": Operation.binaryOperation({ $0 / $1}),
    "=": Operation.equals
]

class CalculatorBrain {
    fileprivate var accumulator = 0.0
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate var operands: [String] = []
    fileprivate var operators: [String] = []
    var description = ""
    var numberTyped = false
    
    fileprivate let descriptionFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        return formatter
    }()
    
    fileprivate var internalProgram = [AnyObject]()
    
    var program: AnyObject {
        get {
            return internalProgram as AnyObject
        }

        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        set(operand: operand)
                    } else if let operation = op as? String {
                        perform(operation: operation)
                    }
                }
            }
        }
    }
    
    fileprivate func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        numberTyped = false
        description = ""
        operands.removeAll()
        operators.removeAll()
    }
    
    func set(operand: Double) {
        numberTyped = true
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    func perform(operation symbol: String){
        if let operation = operations[symbol] {
            internalProgram.append(symbol as AnyObject)
            switch operation {
            case .constant(let constant):
                checkResult()
                operands.append(symbol)
                accumulator = constant
            case .independentOperation(let function):
                checkResult()
                accumulator = function()
                operands.append(descriptionFormatter.string(from: accumulator)!)
                numberTyped = false
            case .unaryOperation(let function):
                parseAccumulator(symbol: symbol)
                accumulator = function(accumulator)
                numberTyped = false
            case .binaryOperation(let function):
                parseAccumulator(symbol: symbol)
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                numberTyped = false
            case .equals:
                if numberTyped {
                    operands.append(descriptionFormatter.string(from: accumulator)!)
                    numberTyped = false
                }
                executePendingBinaryOperation()
                operators.append(symbol)

            }
            parseDescription()

        }
    }
    
    fileprivate func checkResult() {
        if !isPartialResult { // this is a new operation, so clear the stack
            operands.removeAll()
            operators.removeAll()
        }
    }
    
    fileprivate func parseAccumulator(symbol:String) {
        if numberTyped {
            if !isPartialResult { 
                operands.removeAll()
                operators.removeAll()
            }
            operands.append(descriptionFormatter.string(from: accumulator)!)
        } else if isPartialResult {
            operands.append(descriptionFormatter.string(from: accumulator)!)
        }
        operators.append(symbol)
    }
    
    fileprivate func parseDescription() {
        while !operators.isEmpty {
            let op = operators.popLast()!
            if let opType = operations[op], let operand = operands.popLast(){
                switch opType {
                case .unaryOperation:
                    operands.append(op+"("+operand+")")
                case .binaryOperation:
                    if let secondOperand = operands.popLast() {
                        operands.append("(" + secondOperand + operand + ")"+op)
                    } else {
                        operands.append(operand+op)
                    }
                case .equals:
                    if let secondOperand = operands.popLast() {
                        operands.append("(" + secondOperand + operand + ")")
                    } else {
                        operands.append(operand)
                    }
                default:
                    print(op + "is not recognized as any oeprator type")
                    exit(0)
                }
                description = operands.last!
            }
        }
        
    }
    
    fileprivate func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
}
