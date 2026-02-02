//
//  Reusable Items.swift
//  Tether
//
//  Created by Prisha J. on 10/24/25.
//

import SwiftUI

func GradientBackground() -> some View {
    LinearGradient(
        gradient: Gradient(colors: [Color.red.opacity(0.5), Color.pink.opacity(0.4)]),
    startPoint: .leading,
    endPoint: .trailing
    )
    .ignoresSafeArea()
}

struct CapsuleView:View{
    var body: some View{
       
            
    }
}

