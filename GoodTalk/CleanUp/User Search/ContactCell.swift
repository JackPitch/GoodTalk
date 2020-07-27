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
        
    }
    
    func set(user: User) {
        nameLabel.text = user.name
        
        if let url = URL(string: user.imageUrl ?? "") {
            profileImageView.sd_setImage(with: url)
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person"))
        iv.clipsToBounds = true
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 37.5
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "text message"
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
