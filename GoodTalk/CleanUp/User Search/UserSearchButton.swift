//
//  UserSearchButton.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 7/21/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

struct UserSearchButton: View {
    var body: some View {
        Circle()
        .frame(width: 90, height: 90)
            .foregroundColor(Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)))
        .overlay(
            Image(systemName: "pencil")
                .resizable()
                .frame(width: 45, height: 45)
                .foregroundColor(.white)
                .aspectRatio(contentMode: .fit)
        )
        .background(
            Circle()
            .stroke(lineWidth: 4)
                .foregroundColor(Color(#colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)))
        )
    }
}

struct MessagesViewController_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchButton()
    }
}
