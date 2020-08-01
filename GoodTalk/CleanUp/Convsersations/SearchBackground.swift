//
//  CustomSearchBarBackground.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/11/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

struct SearchBackground: View {
    @State var shadowPadding: CGFloat = 0
    @State var searchColor = Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1))
    @State var glassColor = Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(glassColor)
                .frame(width: 20, height: 20)
                .background(
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(searchColor)
                )
                .shadow(color: searchColor.opacity(0.4), radius: 22, x: 0, y: 22)
                .padding(.leading, 24)
            Spacer()
        }
        .frame(width: screen.width - 50, height: 75)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .foregroundColor(.white)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: shadowPadding)
    }
}

struct CustomSearchBarBackground_Previews: PreviewProvider {
    static var previews: some View {
        SearchBackground()
    }
}
