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
    case unaryOperation((Double) -> Double)
    case binaryOperation((Double, Double) -> Double)
    case equals
}

fileprivate let operations: Dictionary<String, Operation> = [
    "π": Operation.constant(M_PI),
    "e": Operation.constant(M_E),
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


extension Double {
    func descriptionFormat() -> String {
        let isInt = floor(self) == self
        if isInt {
            return String(format:"%d", Int(self))
        } else {
            return String(format:"%.03f ", self)

        }
    }
}

class CalculatorBrain {
    fileprivate var accumulator = 0.0
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate var operands: [String] = []
    fileprivate var operators: [String] = []
    var description = ""
    var numberTyped = false
    
    
    func set(operand: Double) {
        accumulator = operand
    }
    
    func perform(operation symbol: String){
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let constant):
                if !isPartialResult { // this is a new operation, so clear the stack
                    operands.removeAll()
                    operators.removeAll()
                }
                operands.append(symbol)
                accumulator = constant
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
                    operands.append(accumulator.descriptionFormat())
                    numberTyped = false
                }
                executePendingBinaryOperation()
                operators.append(symbol)

            }
            parseDescription()

        }
    }
    
    private func parseAccumulator(symbol:String) {
        if numberTyped {
            if !isPartialResult { 
                operands.removeAll()
                operators.removeAll()
            }
            operands.append(accumulator.descriptionFormat())
        } else if isPartialResult {
            operands.append(accumulator.descriptionFormat())
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
