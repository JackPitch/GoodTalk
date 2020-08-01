//
//  GradientBackground.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 7/27/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)), Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))]), startPoint: .bottomLeading, endPoint: .topTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text("GoodTalk")
                    .foregroundColor(Color(#colorLiteral(red: 0.9607843137, green: 0.7098039216, blue: 0.2, alpha: 1)))
                    .font(.system(size: 56, weight: .bold, design: .default))
                    .shadow(color: Color.black.opacity(0.5), radius: 2, x: 4, y: 4)
                Spacer()
                Spacer()
            }
        }
    }
}

struct GradientBackground_Previews: PreviewProvider {
    static var previews: some View {
        GradientBackground()
    }
}
