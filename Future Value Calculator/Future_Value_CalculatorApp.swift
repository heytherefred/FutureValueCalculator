//
//  Future_Value_CalculatorApp.swift
//  Future Value Calculator
//
//  Created by Peter Johnstone on 2023-01-19.
//

import SwiftUI

@main
struct Future_Value_CalculatorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
