//
//  EmptySearchView.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/11/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
            .resizable()
                .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(UIColor.systemGray3))
            .frame(width: 100, height: 100)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 4, y: 4)
            
            Text("Search")
            .bold()
            .foregroundColor(Color(UIColor.systemGray3))
            .background(Color.clear)
                .padding(.bottom, 50)
        }
    }
}



struct EmptySearchView_Previews: PreviewProvider {
    static var previews: some View {
        EmptySearchView()
    }
}
