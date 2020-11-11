//
//  DeleteContactPage.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 11/5/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

protocol DeleteContactDelegate: class {
    func deleteContact()
}

class DeleteContactPage: UIViewController {
    
    var delegate: DeleteContactDelegate!
    
    let stringHelper = StringHelper()
    
    let boxSize: CGFloat = screen.width - 120
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurView)
        blurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 60, paddingBottom: 0, paddingRight: 60, width: 0, height: boxSize / 1.5)
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(deleteButton)
        let deleteTitle = stringHelper.generateAttributedString(titleName: "Delete", imageName: nil, fontSize: 18)
        deleteButton.setAttributedTitle(deleteTitle, for: .normal)
        deleteButton.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: boxSize / 2.2, height: 50)
        
        view.addSubview(cancelButton)
        let cancelTitle = stringHelper.generateAttributedString(titleName: "Cancel", imageName: nil, fontSize: 18)
        cancelButton.setAttributedTitle(cancelTitle, for: .normal)
        cancelButton.anchor(top: nil, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 8, width: boxSize / 2.2, height: 50)
        
        view.addSubview(warningLabel)
        warningLabel.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 22
        view.layer.shadowOpacity = 0.3
        view.layer.cornerRadius = 12
        return view
    }()
    
    let blurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 1, alpha: 0.6)
        return view
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Remove This Contact?"
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDelete() {
        dismiss(animated: true) {
            self.delegate.deleteContact()
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
