//
//  Extensions.swift
//  Calculator
//
//  Created by Augusto on 12/20/16.
//  Copyright © 2016 Nihil Games. All rights reserved.
//

import Foundation

extension NumberFormatter {
    func string(from number: Double) -> String? {
        return self.string(from: NSNumber(value: number))
    }
}
