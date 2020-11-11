//
//  ContactCell.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/8/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImage

class ContactCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 75, height: 75)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(nameLabel)
        nameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(emailLabel)
        emailLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        //setupInfoButton()
    }
    
    func setupInfoButton() {
        addSubview(infoLabel)
        infoLabel.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 20, height: 20)
        infoLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(infoButton)
        infoButton.anchor(top: infoLabel.topAnchor, left: infoLabel.leftAnchor, bottom: infoLabel.bottomAnchor, right: infoLabel.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func set(user: User, userInfoEnabled: Bool) {
        nameLabel.text = user.name
        emailLabel.text = user.email
        if user.imageUrl == "" {
            profileImageView.image = UIImage(systemName: "person.crop.circle")
            profileImageView.tintColor = .gray
        } else {
            if let url = URL(string: user.imageUrl ?? "") {
                profileImageView.sd_setImage(with: url)
            }
        }
        userInfoEnabled ? (infoButton.alpha = 1) : (infoButton.alpha = 0)
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 37.5
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name here"
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "email here"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .gray
        return label
    }()
    
    let infoLabel: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "info.circle"))
        iv.clipsToBounds = true
        iv.tintColor = .systemGray
        return iv
    }()
    
    let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleUserInfo(sender:)), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUserInfo(sender: UIButton) {
        print("go to user info page")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
