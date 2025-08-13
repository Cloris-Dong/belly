//
//  ContentView.swift
//  Belly
//
//  Created by Han Dong on 8/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello from Xcode!")
                .font(.title)
                .padding()
                .background(.yellow)
                .cornerRadius(12)

            Text("This line was edited in Xcode")
                .font(.subheadline)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
