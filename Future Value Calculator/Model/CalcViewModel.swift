//
//  ViewModel.swift
//  Future Value Calculator
//
//  Created by Peter Johnstone on 2023-02-04.
//

import Foundation

enum CalcName {
	case presentValue
	case futureValue
	case interestRate
	case numberPeriods
}

struct CalcField {
	var name: CalcName
	var text: String = ""
	let formatter: NumberFormatter
	var value: NSNumber? {
		get {
			if(text.isEmpty) {
				return nil
			}
//				NSLog(String(describing: name) + " " + text)
			return parse(cleanNumberString())
		}
		set(newValue) {
			if let val = newValue {
				text = formatter.string(from: val) ?? ""
			}
			else {
				text = ""
			}
		}
		
	}
	let parse: (String) -> NSNumber?
	
	init(name: CalcName, parse: @escaping (String) -> NSNumber?, formatter: NumberFormatter) {
		self.name = name
		self.parse = parse
		self.formatter = formatter
	}
	
	private func cleanNumberString() -> String {
		let pattern = "[^0-9" + formatter.decimalSeparator + "]" //+ formatter.groupingSeparator + "]"
		guard let regex = try? Regex(pattern) else {
			return ""
		}
		return text.replacing(regex, with: "")
	}
	
}

struct Calculation {
	let displayName: String
	let validator: () -> Bool
	var dependsOn: [Calculation]
	let name: CalcName
}

class CalcViewModel: ObservableObject {
	@Published var numberPeriods: CalcField
	@Published var interestRate: CalcField
	@Published var futureValue: CalcField
	@Published var presentValue: CalcField
	
	@Published var calculationName: CalcName?
	
	private let errorMessageFormat = "This value is required for the %@ calculation and it has to be a number"
	private var calculations: [CalcName: Calculation] = [:]
	private var percentFormatter = NumberFormatter()
	private var currencyFormatter = NumberFormatter()
	private var intFormatter = NumberFormatter()
	
	init() {
		percentFormatter.numberStyle = .percent
		percentFormatter.maximumFractionDigits = 2
		percentFormatter.percentSymbol = "" //using a prefix image instead
		
		currencyFormatter.numberStyle = .currency
		currencyFormatter.minimumFractionDigits = 2
		currencyFormatter.maximumFractionDigits = 2
		currencyFormatter.currencySymbol = "" //using a prefix image instead
		
		numberPeriods = CalcField(name: CalcName.numberPeriods, parse: CalcViewModel.intParse, formatter: intFormatter)
		interestRate = CalcField(name: CalcName.interestRate, parse: CalcViewModel.doubleParse, formatter: percentFormatter)
		futureValue = CalcField(name: CalcName.futureValue, parse: CalcViewModel.doubleParse, formatter: currencyFormatter)
		presentValue = CalcField(name: CalcName.presentValue, parse: CalcViewModel.doubleParse, formatter: currencyFormatter)
		
		var numberPeriodsCalc = Calculation(displayName: "Number of Periods", validator: numberPeriodsValid, dependsOn: [], name: CalcName.numberPeriods)
		var interestRateCalc = Calculation(displayName: "Interest Rate", validator: interestRateValid, dependsOn: [], name: CalcName.interestRate)
		var futureValueCalc = Calculation(displayName: "Future Value", validator: futureValueValid, dependsOn: [], name: CalcName.futureValue)
		let presentValueCalc = Calculation(displayName: "Present Value", validator: presentValueValid,
																			 dependsOn: [futureValueCalc, interestRateCalc, numberPeriodsCalc],
																			 name: CalcName.presentValue)
		numberPeriodsCalc.dependsOn.append(contentsOf: [interestRateCalc, futureValueCalc, presentValueCalc])
		interestRateCalc.dependsOn.append(contentsOf: [numberPeriodsCalc, futureValueCalc, presentValueCalc])
		futureValueCalc.dependsOn.append(contentsOf: [numberPeriodsCalc, interestRateCalc, presentValueCalc])
		calculations[numberPeriodsCalc.name] = numberPeriodsCalc
		calculations[interestRateCalc.name] = interestRateCalc
		calculations[futureValueCalc.name] = futureValueCalc
		calculations[presentValueCalc.name] = presentValueCalc
	}
	
	private static func intParse(text: String) -> NSNumber? {
		if let value = Int(text) {
			return NSNumber(value: value)
		}
		return nil
	}
	private static func doubleParse(text: String) -> NSNumber? {
		if let value = Double(text) {
			return NSNumber(value: value)
		}
		return nil
	}
	
	private var errorMessage: String {
		guard let name = calculationName,
					let calc = calculations[name] else {
			return ""
		}
		return String(format: errorMessageFormat, calc.displayName)
	}
	
	var numberPeriodsErrorMessage: String {
		return getErrorMessage(CalcName.numberPeriods)
	}
	var interestRateErrorMessage: String {
		return getErrorMessage(CalcName.interestRate)
	}
	var futureValueErrorMessage: String {
		return getErrorMessage(CalcName.futureValue)
	}
	var presentValueErrorMessage: String {
		return getErrorMessage(CalcName.presentValue)
	}
	
	private func getErrorMessage(_ fieldName: CalcName)->String {
		guard let calcName = calculationName,
					let calculation = calculations[calcName],
					let dependency = calculation.dependsOn.first(where: {(calc: Calculation) -> Bool in return calc.name == fieldName}) else
		{
			return ""
		}
		return dependency.validator() ? "" : String(format: errorMessageFormat, calculation.displayName)
	}
	
	// MARK: - Validation Functions
	var validForPeriodCalc: Bool {
		get {
			interestRateValid() && futureValueValid() && presentValueValid()
		}
		set {
			//can't bind to this without a setter WTF. This is bullshit. Why is there no one-way binding?
		}
	}
	var validForInterestRateCalc: Bool {
		get {
			numberPeriodsValid() && futureValueValid() && presentValueValid()
		}
		set {
			//can't bind to this without a setter WTF. This is bullshit. Why is there no one-way binding?
		}
	}
	var validForFutureValueCalc: Bool {
		get {
			return numberPeriodsValid() && interestRateValid() && presentValueValid()
		}
		set {
			//can't bind to this without a setter WTF. This is bullshit. Why is there no one-way binding?
		}
	}
	var validForPresentValueCalc: Bool {
		get {
			numberPeriodsValid() && interestRateValid() && futureValueValid()
		}
		set {
			//can't bind to this without a setter WTF. This is bullshit. Why is there no one-way binding?
		}
	}
	
	func numberPeriodsValid() -> Bool {
		numberPeriods.value != nil
	}
	func interestRateValid() -> Bool {
		interestRate.value != nil
	}
	func futureValueValid() -> Bool {
		futureValue.value != nil
	}
	func presentValueValid() -> Bool {
		return presentValue.value != nil
	}
}
