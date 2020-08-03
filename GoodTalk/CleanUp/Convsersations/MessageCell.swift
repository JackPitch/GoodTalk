//
//  MessageCell.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 6/29/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImage

class MessageCell: UITableViewCell {
    
    let uid = Auth.auth().currentUser?.uid ?? ""
    var chatPartnerID: String?
    var imageUrl: String?
    var timeStamp: String?
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileView)
        profileView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 75, height: 75)
        profileView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(messageTimeLabel)
        messageTimeLabel.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        messageTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(textMessageLabel)
        textMessageLabel.anchor(top: nil, left: profileView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 16, paddingRight: 0, width: 200, height: 0)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 150, height: 0)
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func set(message: Message) {
        
        if let textMessage = message.textMessage {
            textMessageLabel.text = textMessage
            textMessageLabel.font = .systemFont(ofSize: 18)
        }
        
        if message.imageUrl != nil {
            textMessageLabel.text = "1 Image"
            textMessageLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        }
        
        if(message.toID == Auth.auth().currentUser?.uid) {
            getProfileImage(forName: message.fromID ?? "")
        } else {
            getProfileImage(forName: message.toID ?? "")
        }
        
        if let time = message.timeStamp?.doubleValue {
            let timeStampDate = Date(timeIntervalSince1970: time)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            self.timeStamp = dateFormatter.string(from: timeStampDate)
            messageTimeLabel.text = timeStamp
        }
        
        if message.fromID == Auth.auth().currentUser?.uid {
            chatPartnerID = message.toID
        } else {
            chatPartnerID = message.fromID
        }
        if let id = chatPartnerID {
            Database.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: String] {
                    DispatchQueue.main.async {
                        self.nameLabel.text = dictionary["name"] ?? "Unkown"
                        self.imageUrl = dictionary["imageUrl"] ?? "Unknown"
                    }
                }
            }, withCancel: nil)
        }
    }
    
    fileprivate func getProfileImage(forName: String) {
        Database.database().reference().child("users").child(forName).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let imageUrl = dictionary["imageUrl"] as! String
                if imageUrl == "" {
                    self.profileView.image = UIImage(systemName: "person.crop.circle")
                    self.profileView.tintColor = .gray
                } else {
                    guard let url = URL(string: imageUrl) else { return }
                    self.profileView.sd_setImage(with: url)
                }
            }
        }
    }
        
    let profileView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .gray
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 37.5
        iv.clipsToBounds = true
        return iv
    }()
    
    let messageTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Tiem stamp"
        label.textColor = .gray
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
        
    let textMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "textMessage"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func downloadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            if let err = err {
                print("see message cell", err)
                return
            }
            
            guard let data = data else { return }
            
            
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.profileView.image = image
            }
        }
    .resume()
    }
}
