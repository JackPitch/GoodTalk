//
//  CustomShap.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 10/12/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

struct CustomShape : Shape {
     
     var corner : UIRectCorner
     var radii : CGFloat
     
     func path(in rect: CGRect) -> Path {
         
         let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: radii, height: radii))
         
         return Path(path.cgPath)
     }
 }
