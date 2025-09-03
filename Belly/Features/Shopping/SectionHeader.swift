//
//  SectionHeader.swift
//  Belly
//
//  Created by Han Dong on 8/14/25.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundColor(.primaryText)
            
            Text("(\(count))")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeader(title: "To Buy", count: 5, color: .blue)
        SectionHeader(title: "Purchased", count: 3, color: .green)
    }
    .padding()
}
