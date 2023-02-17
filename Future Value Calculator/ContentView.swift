//
//  ContentView.swift
//  Future Value Calculator
//
//  Created by Peter Johnstone on 2023-01-19.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var viewModel = CalcViewModel()
	@State private var showErrors = false
	
	var body: some View {
		NavigationStack {
			Form {
				
				VStack {
					HStack {
						
						HStack {
							Image(systemName: "dollarsign")
							FieldTextView("Present Value", text: $viewModel.presentValue.text, errorMessage: viewModel.presentValueErrorMessage)
						}
						//						Text("\(viewModel.presentValue.text)")
						
						CalculateButtonView(valid: $viewModel.validForPresentValueCalc, action: {
							
							viewModel.calculationName = CalcName.presentValue
							if(!viewModel.validForPresentValueCalc) {
								return
							}
							
							viewModel.presentValue.value = NSNumber(value: Calculations.presentValue(
								futureValue: viewModel.futureValue.value!.doubleValue,
								interestRate: viewModel.interestRate.value!.doubleValue,
								numberPeriods: viewModel.numberPeriods.value!.doubleValue))
						})
					}
					HStack {
						HStack {
							FieldTextView("Interest Rate", text: $viewModel.interestRate.text, errorMessage: viewModel.interestRateErrorMessage)
							Image(systemName: "percent")
						}
						//						Text("\(viewModel.interestRate.text)")
						CalculateButtonView(valid: $viewModel.validForInterestRateCalc, action: {
							viewModel.calculationName = CalcName.interestRate
							if(!viewModel.validForInterestRateCalc) {
								return
							}
							viewModel.interestRate.value = NSNumber(value: Calculations.interestRate(
								presentValue: viewModel.presentValue.value!.doubleValue,
								futureValue: viewModel.futureValue.value!.doubleValue,
								numberPeriods: viewModel.numberPeriods.value!.doubleValue))
						})
					}
					HStack {
						FieldTextView("Number of Periods", text: $viewModel.numberPeriods.text, errorMessage: viewModel.numberPeriodsErrorMessage)
						//						Text("\(viewModel.numberPeriods.text)")
						
						CalculateButtonView(valid: $viewModel.validForPeriodCalc, action: {
							viewModel.calculationName = CalcName.numberPeriods
							if(!viewModel.validForPeriodCalc) {
								return
							}
							viewModel.numberPeriods.value = NSNumber(value: Calculations.numberPeriods(
								presentValue: viewModel.presentValue.value!.doubleValue,
								futureValue: viewModel.futureValue.value!.doubleValue,
								interestRate: viewModel.interestRate.value!.doubleValue))
						})
					}
					HStack {
						HStack {
							Image(systemName: "dollarsign")
							FieldTextView("Future Value", text: $viewModel.futureValue.text, errorMessage: viewModel.futureValueErrorMessage)
						}
						//						Text("\(viewModel.futureValue.text)")
						
						CalculateButtonView(valid: $viewModel.validForFutureValueCalc, action: {
							viewModel.calculationName = CalcName.futureValue
							if(!viewModel.validForFutureValueCalc) {
								return
							}
							
							viewModel.futureValue.value = NSNumber(value: Calculations.futureValue(
								presentValue: viewModel.presentValue.value!.doubleValue,
								interestRate: viewModel.interestRate.value!.doubleValue,
								numberPeriods: viewModel.numberPeriods.value!.doubleValue))
							
						})
					}
					
				}.navigationTitle("Future Value Calc")
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

struct CalculateButtonView: View {
	
	@Binding private var valid: Bool
	let action: () -> Void
	
	init(valid: Binding<Bool>, action: @escaping () -> Void) {
		self._valid = valid
		self.action = action
	}
	var body: some View {
		
		Button(action: self.action)
		{
			Text("Calculate")
				.foregroundColor(.white)
				.padding(.vertical, 5)
				.padding(.horizontal)
				.background(Capsule().fill(Color.accentColor))
		}
		.opacity(valid ? 1 : 0.6)
		//		.disabled(!valid)
		.buttonStyle(BorderlessButtonStyle())
	}
}


struct FieldTextView: View {
	@Binding var text: String
	var errorMessage: String
	var label: String
	
	init(_ label: String, text: Binding<String>, errorMessage: String) {
		self.label = label
		self._text = text
		self.errorMessage = errorMessage
	}
	
	var body: some View {
		VStack {
			ZStack(alignment: .leading) {
				Text(label)
					.foregroundColor(text.isEmpty ? Color(.placeholderText) : .accentColor)
					.offset(y: (text.isEmpty ? 0 : -25))
					.scaleEffect(text.isEmpty ? 1 : 0.8, anchor: .leading)
				TextField("", text: $text)
					.keyboardType(.numberPad)
			}
			.padding(.top, 15)
			.animation(.default, value: text)
			
			Text(errorMessage).font(.caption).foregroundColor(.red)
		}
	}
}
