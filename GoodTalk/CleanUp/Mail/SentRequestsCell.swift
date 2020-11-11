//
//  SentRequestsCell.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 9/20/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

class SentRequestsCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        addSubview(mailImageView)
        mailImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        
        addSubview(profileLabel)
        profileLabel.anchor(top: topAnchor, left: mailImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(emailLabel)
        emailLabel.anchor(top: profileLabel.bottomAnchor, left: mailImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
        
    let profileLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile Name"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email Here"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    let mailImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope.badge.fill"))
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.tintColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        return iv
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
