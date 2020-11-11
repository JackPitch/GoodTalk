//
//  ContactInfoPage.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 11/5/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//
import Firebase
import SwiftUI

protocol ContactInfoPageDelegate: class {
    func deleteContact(user: User)
}

class ContactInfoPage: UIViewController, DeleteContactDelegate {
    
    var user: User? {
        didSet {
            nameLabel.text = user?.name
            emailLabel.text = user?.email
            if let url = URL(string: user?.imageUrl ?? "") {
                profileImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    var delegate: ContactInfoPageDelegate!
    
    let stringHelper = StringHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
         
        view.addSubview(emailLabel)
        emailLabel.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
         
        view.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: nil, bottom: nameLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 200, height: 200)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(deleteButton)
        deleteButton.anchor(top: emailLabel.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: screen.width / 2.2, height: 55)
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let title = stringHelper.generateAttributedString(titleName: "Delete Contact", imageName: nil, fontSize: 18)
        deleteButton.setAttributedTitle(title, for: .normal)
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textColor = .systemGray2
        label.textAlignment = .center
        return label
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.circle"))
        iv.layer.cornerRadius = 100
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.tintColor = .systemGray3
        return iv
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(presentDelete), for: .touchUpInside)
        return button
    }()
        
    @objc func presentDelete() {
        let deletePopOver = DeleteContactPage()
        deletePopOver.delegate = self
        deletePopOver.modalPresentationStyle = .overFullScreen
        deletePopOver.modalTransitionStyle = .crossDissolve
        present(deletePopOver, animated: true)
    }
    
    func deleteContact() {
        navigationController?.popViewController(animated: true)
        guard let user = user else { return }
        delegate.deleteContact(user: user)
    }
}
