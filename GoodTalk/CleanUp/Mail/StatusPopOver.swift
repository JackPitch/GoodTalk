//
//  StatusPopOver.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 9/24/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

class StatusPopOver: UIViewController {
    
    var delegate: RequestDelegate!
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.name
            emailLabel.text = user?.email
            if let imageUrl = user?.imageUrl {
                guard let url = URL(string: imageUrl) else { return }
                profileImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurView)
        blurView.frame = view.bounds
        
        setupContainerView()
        
        setupProfileLabels()
        
        setupAcceptOrDelete()
        
        setupDoneButton()
    }
    
    func setupContainerView() {
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: screen.width / 1.5)
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupProfileLabels() {
        let requestFromLabel: UILabel = {
            let label = UILabel()
            label.text = "Request From:"
            label.font = .systemFont(ofSize: 20, weight: .regular)
            return label
        }()
        
        view.addSubview(requestFromLabel)
        requestFromLabel.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        requestFromLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: requestFromLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        view.addSubview(emailLabel)
        emailLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupAcceptOrDelete() {
        view.addSubview(acceptButton)
        acceptButton.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: screen.width / 2.8, height: 60)
        
        view.addSubview(deleteButton)
        deleteButton.anchor(top: nil, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 8, width: screen.width / 2.8, height: 60)
    }
    
    func setupDoneButton() {
        view.addSubview(doneButtonImage)
        doneButtonImage.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 50, height: 50)
        
        view.addSubview(doneButton)
        doneButton.anchor(top: doneButtonImage.topAnchor, left: doneButtonImage.leftAnchor, bottom: doneButtonImage.bottomAnchor, right: doneButtonImage.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 3
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.circle"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50
        iv.tintColor = .systemGray5
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username Here"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        return button
    }()
    
    let doneButtonImage: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        button.backgroundColor = .systemGray
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return button
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "Email Here"
        return label
    }()
    
    @objc func handleAccept() {
        guard let user = user else { return }
        self.dismiss(animated: true) {
            self.delegate.didTapAccept(user: user)
        }
    }
    
    @objc func handleDelete() {
        guard let user = user else { return }
        self.dismiss(animated: true) {
            self.delegate.didTapDelete(user: user)
        }
    }
    
    @objc func handleDone() {
        dismiss(animated: true, completion: nil)
    }
}

