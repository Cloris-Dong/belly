//
//  BellyApp.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

@main
struct BellyApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .preferredColorScheme(.light) // Force light mode only
        }
    }
}
