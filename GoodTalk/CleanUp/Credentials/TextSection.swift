//
//  TextSection.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/18/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

class TextSection: UIView, UITextFieldDelegate {
    
    init(imageName: String, textName: String) {
        super.init(frame: .zero)
        
        textField.placeholder = textName
        addSubview(textField)
        textField.delegate = self
        textField.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: screen.width - 160, height: 50)
        textField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let iconImage = UIHostingController(rootView: IconView(named: imageName))
        addSubview(iconImage.view)
        iconImage.view.anchor(top: nil, left: nil, bottom: nil, right: textField.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        iconImage.view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(divider)
        divider.anchor(top: iconImage.view.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: screen.width - 110, height: 3)
        divider.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name:"
        return tf
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
