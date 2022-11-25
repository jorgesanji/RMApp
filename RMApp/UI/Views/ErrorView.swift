//
//  File.swift
//  RMApp
//
//  Created by jorge Sanmartin on 25/11/22.
//

import SwiftUI

struct ErrorView: View {
    
    let action: (() -> Void)
    
    var body: some View {
        VStack {
            
            Text("Please try again later")
                .foregroundColor(.black)
                .font(.system(size: 14, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .padding(5)
            
            Button("Retry") {
                action()
            }.padding(.init(top: 0, leading: 5, bottom: 5, trailing: 5))
            
        }
    }
}
