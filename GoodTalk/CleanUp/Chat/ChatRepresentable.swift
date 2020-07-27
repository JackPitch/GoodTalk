//
//  ChatRepresentable.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/1/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

struct ChatRepresentable: UIViewControllerRepresentable {
    @State var chatPartnerId: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ChatRepresentable>) -> UIViewController {
        let viewController = ChatViewController()
        viewController.chatPartnerId = self.chatPartnerId
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ChatRepresentable>) {
    }
    
    typealias UIViewControllerType = UIViewController
}
