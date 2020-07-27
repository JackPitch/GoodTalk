//
//  ResizableTextField.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 7/21/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

struct ResizableTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            self.height = uiView.contentSize.height
        }
        uiView.text = self.text
    }
    
    func makeCoordinator() -> Coordinator {
        return ResizableTextField.Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = true
        view.isScrollEnabled = true
        view.text = "Enter Message"
        view.font = .systemFont(ofSize: 18)
        view.textColor = .gray
        view.delegate = context.coordinator
        return view
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ResizableTextField
        
        init(parent: ResizableTextField) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if self.parent.text == "" {
                textView.text = ""
                textView.textColor = .black
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.height = textView.contentSize.height
                self.parent.text = textView.text
            }
        }
    }
}



extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

