//
//  Calculations.swift
//  Future Value Calculator
//
//  Created by Peter Johnstone on 2023-02-12.
//

import Foundation

struct Calculations {
	
	static func futureValue(presentValue: Double, interestRate: Double, numberPeriods: Double) -> Double {
		return presentValue * pow(1 + interestRate/100, numberPeriods)
	}
	
	static func presentValue(futureValue: Double, interestRate: Double, numberPeriods: Double) -> Double {
		return futureValue / pow(1 + interestRate/100, numberPeriods)
	}
	
	static func interestRate(presentValue: Double, futureValue: Double, numberPeriods: Double) -> Double {
		return pow(10, (log10(futureValue) - log10(presentValue))/numberPeriods) - 1
	}
	
	static func numberPeriods(presentValue: Double, futureValue: Double, interestRate: Double) -> Double {
		return (log(futureValue) - log(presentValue)) / log(1 + interestRate/100)
	}
	
}
