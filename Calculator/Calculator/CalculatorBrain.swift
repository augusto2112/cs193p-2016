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
    
    var description: String {
        get {
            enum CalculatorState {
                case started
                case firstOperandSet
                case binaryOperationSet
                case secondOperandSet
                case concluded
            }
        
            
            var state = CalculatorState.started
            var firstOperand = ""
            var secondOperand = ""
            var currentOperator = ""
            
            
            for value in internalProgram {
                switch (state, value) {
                case (.started, is Double), (.firstOperandSet, is Double),
                     (.concluded, is Double):
                    firstOperand = String(describing: value)
                    state = .firstOperandSet
                case (.binaryOperationSet, is Double), (.secondOperandSet, is Double):
                    secondOperand = String(describing:value)
                    state = .secondOperandSet
                case (_, is String):
                    let op = value as! String
                    if let operationType = operations[op] {
                        switch (state, operationType) {
                        case (.started, .constant), (.started, .independentOperation),
                             (.firstOperandSet, .constant), (.firstOperandSet, .independentOperation),
                             (.concluded, .constant), (.concluded, .independentOperation):
                            firstOperand = op
                            state = .firstOperandSet
                        case (.firstOperandSet, .unaryOperation), (.concluded, .unaryOperation):
                            firstOperand = op + "(" + firstOperand + ")"
                            state = .firstOperandSet
                        case (.firstOperandSet, .binaryOperation), (.binaryOperationSet, .binaryOperation),
                             (.concluded, .binaryOperation):
                            currentOperator = op
                            state = .binaryOperationSet
                        case (.binaryOperationSet, .constant), (.binaryOperationSet, .independentOperation),
                             (.secondOperandSet, .constant), (.secondOperandSet, .independentOperation):
                            secondOperand = op
                            state = .secondOperandSet
                        case (.binaryOperationSet, .unaryOperation), (.secondOperandSet, .unaryOperation):
                            secondOperand = op + "(" + firstOperand + ")"
                            state = .secondOperandSet
                        case (.secondOperandSet, .equals):
                            state = .concluded
                            fallthrough
                        case (.secondOperandSet, .binaryOperation):
                            firstOperand = "(" + firstOperand + currentOperator + secondOperand + ")"
                            currentOperator = op
                        default:
                            break
                        }
                    } else {
                        switch state {
                        case .started, .firstOperandSet, .concluded:
                            firstOperand = op
                            state = .firstOperandSet
                        case .binaryOperationSet, .secondOperandSet:
                            secondOperand = op
                            state = .secondOperandSet
                        }
                    }
                default:
                    break
                }
            }
            
            switch state {
            case .binaryOperationSet, .secondOperandSet:
                return firstOperand + currentOperator
            default:
                return firstOperand
            }
        }
    }
    
    
    var errorOccurred: Bool {
        return result.isNaN || result.isInfinite || result.isSubnormal
    }
    
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
            rerun(program: newValue)
        }
    }
    
    func removeLastOp() {
        if !internalProgram.isEmpty {
            var op = internalProgram.removeLast() as? String
            while op == "=" && !internalProgram.isEmpty { // if the last op was a "=", remove the one before as well
                op = internalProgram.removeLast() as? String
            }
        }
        rerun(program: program)
        print(accumulator)
    }
    
    fileprivate func rerun(program: AnyObject) {
        clear()
        if let arrayOfOps = program as? [AnyObject] {
            for op in arrayOfOps {
                if let operand = op as? Double {
                    set(operand: operand)
                } else if let operationOrVariable = op as? String {
                    if operations[operationOrVariable] != nil {
                        perform(operation: operationOrVariable)
                    } else if variableValues[operationOrVariable] != nil{
                        set(operand: operationOrVariable)
                    }
                }
            }
        }

    }
    
    fileprivate func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    func set(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    func perform(operation symbol: String){
        if let operation = operations[symbol] {
            internalProgram.append(symbol as AnyObject)
            switch operation {
            case .constant(let constant):
                accumulator = constant
            case .independentOperation(let function):
                accumulator = function()
            case .unaryOperation(let function):
                accumulator = function(accumulator)
            case .binaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .equals:
                executePendingBinaryOperation()
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

    var variableValues: Dictionary<String, Double> = [:] {
        didSet {
            rerun(program: program)
        }
    }

    func set(operand variable: String) {
        accumulator = variableValues[variable] ?? 0.0
        internalProgram.append(variable as AnyObject)
    }
}




























































