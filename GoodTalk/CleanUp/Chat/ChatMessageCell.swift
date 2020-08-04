//
//  TestCell.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/1/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

class ChatMessageCell: UITableViewCell {
    
    var chatViewController: ChatViewController?
    
    var textMessage: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(bubbleView)
        addSubview(messageLabel)
        addSubview(messageImageView)
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: screen.width - 100).isActive = true
    }
    
    func set(message: Message) {
        messageLabel.text = message.textMessage
        if(message.fromID == Auth.auth().currentUser?.uid) {
            setupRightOrientation()
        } else {
           setupLeftOrientation()
        }
        
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(lessThanOrEqualToConstant: screen.width - 180).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: screen.width - 120).isActive = true
        
        if let messageImageUrl = message.imageUrl {
            messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            messageImageView.isHidden = false
            bubbleView.bottomAnchor.constraint(equalTo: messageImageView.bottomAnchor).isActive = true
            bubbleView.topAnchor.constraint(equalTo: messageImageView.topAnchor).isActive = true
            bubbleView.backgroundColor = UIColor.clear

        } else {
            messageImageView.isHidden = true
        }
    }
    
    var messageRightAnchor: NSLayoutXAxisAnchor?
    var messageLeftAnchor: NSLayoutXAxisAnchor?

    func setupRightOrientation() {
        messageLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 18, width: 0, height: 0)

        bubbleView.anchor(top: messageLabel.topAnchor, left: messageLabel.leftAnchor, bottom: messageLabel.bottomAnchor, right: messageLabel.rightAnchor, paddingTop: -8, paddingLeft: -12, paddingBottom: -8, paddingRight: -12, width: 0, height: 0)
        bubbleView.backgroundColor = UIColor(red: 245 / 255, green: 201 / 255, blue: 88 / 255, alpha: 1)
        messageLabel.textColor = .white
        
        messageImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    func setupLeftOrientation() {
        messageLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 18, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)

        bubbleView.anchor(top: messageLabel.topAnchor, left: messageLabel.leftAnchor, bottom: messageLabel.bottomAnchor, right: messageLabel.rightAnchor, paddingTop: -8, paddingLeft: -12, paddingBottom: -8, paddingRight: -12, width: 0, height: 0)

        bubbleView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        messageLabel.textColor = .black
        
        messageImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "something"
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
