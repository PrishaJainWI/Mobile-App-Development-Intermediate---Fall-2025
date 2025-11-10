//
//  Home.swift
//  Tether
//
//  Created by local on 10/24/25.
//

import SwiftUI

import SwiftUI

struct Home: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 700)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
    }
}

#Preview {
    Home()
}
