//
//  UserProfilePageViewController.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 9/18/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase
import Lottie

class UserProfilePageViewController: UIViewController {
    
    var timer: Timer?
    
    var lottieVC = UIHostingController(rootView: LottieCard(animationMessage: "Request Sent!"))
    
    var otherUserSentRequest = false
    
    let mailHandler = MailHandler()
    
    let stringHelper = StringHelper()
        
    var user: User? {
        didSet {
            nameLabel.text = user?.name
            emailLabel.text = user?.email
            guard let url = URL(string: user?.imageUrl ?? "") else { return }
            profileImageView.layer.borderColor = UIColor.black.cgColor
            profileImageView.layer.borderWidth = 1.5
            profileImageView.sd_setImage(with: url, completed: nil)
        }
    }
        
    func didTapUser(user: User) {
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        checkUserStatus()
                
        view.addSubview(nameLabel)
        nameLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(emailLabel)
        emailLabel.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: nil, bottom: nameLabel.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 200, height: 200)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(addButton)
        addButton.anchor(top: emailLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 50)
        addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
    
    let plusImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "plus"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.clipsToBounds = true
        return iv
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "plus")
        imageAttachment.image = imageAttachment.image?.withTintColor(.white, renderingMode: .alwaysOriginal)

        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " Add Contact"))
        fullString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .semibold)], range: NSRange(0..<fullString.length))
        
        button.setAttributedTitle(fullString, for: .normal)
        button.addTarget(self, action: #selector(handleRequest), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = .zero
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 22
        return button
    }()
    
    let alreadyRequestedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemGray2
        label.text = "This user has already sent a request to you!"
        label.numberOfLines = 0
        return label
    }()
    
    func otherUser_alreadyRequested_label() {
        view.addSubview(alreadyRequestedLabel)
        alreadyRequestedLabel.anchor(top: addButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: screen.width / 2, height: 0)
        alreadyRequestedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    //MARK:- Firebase Func
    
    @objc func handleRequest() {
        if(otherUserSentRequest) {
            guard let parnterId = user?.uuid else { return }
            mailHandler.addContact(partnerId: parnterId)
            mailHandler.deleteFromRequests(partnerId: parnterId)
            lottieVC = UIHostingController(rootView: LottieCard(animationMessage: "Added Contact!"))
            presentAddedContact()
            alreadyRequestedLabel.removeFromSuperview()
            
            let title = stringHelper.generateAttributedString(titleName: "Already Added", imageName: nil, fontSize: 18)
            addButton.setAttributedTitle(title, for: .normal)
            addButton.isEnabled = false
        } else {
            presentAddedContact()
            guard let toID = user?.uuid else { return }
            guard let currentUser = Auth.auth().currentUser?.uid else { return }
            let mailRef = Database.database().reference().child("mail")
            let values = ["requestTo": toID, "requestFrom": currentUser]
            
            guard let key = mailRef.childByAutoId().key else { return }
            mailRef.child(key).updateChildValues(values)
        }
    }
    
    
    //MARK:- Check User Status
    
    func checkUserStatus() {
        checkAlreadyAdded()
        checkAlreadyInContacts()
        check_If_OtherUser_HasSentRequest()
    }
    
    func checkAlreadyAdded() {
        guard let partnerId = user?.uuid else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let mailRef = Database.database().reference().child("mail")
        mailRef.queryOrdered(byChild: "requestTo").queryEqual(toValue: partnerId).observe(.childAdded) { [weak self] (snapshot) in
            guard let self = self else { return }
            mailRef.child(snapshot.key).observeSingleEvent(of: .value) { (snap) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let requestFrom = dictionary["requestFrom"] as! String
                    if requestFrom == uid {
                        self.addButton.isEnabled = false
                        let title = self.stringHelper.generateAttributedString(titleName: "Request Sent", imageName: nil, fontSize: 18)
                        
                        self.addButton.setAttributedTitle(title, for: .normal)
                        self.addButton.backgroundColor = .systemGray
                    }
                }
            }
        }
    }
    
    func checkAlreadyInContacts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let usersRef = Database.database().reference().child("users")
        usersRef.child(uid).child("Contacts").observe(.childAdded) { [weak self] (snapshot) in
            guard let self = self else { return }
            usersRef.child(snapshot.key).observeSingleEvent(of: .value) { (snap) in
                
                if let dict = snap.value as? [String: AnyObject] {
                    var partner = User(dictionary: dict)
                    partner.uuid = snapshot.key
                    
                    if(self.user?.uuid == partner.uuid) {
                        self.addButton.isEnabled = false
                        let title = self.stringHelper.generateAttributedString(titleName: "Already Added", imageName: nil, fontSize: 18)
                        self.addButton.setAttributedTitle(title, for: .normal)
                        self.addButton.backgroundColor = .systemGray
                    }
                }
            }
        }
    }
        
    func check_If_OtherUser_HasSentRequest() {
        guard let partnerId = user?.uuid else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let mailRef = Database.database().reference().child("mail")
        mailRef.queryOrdered(byChild: "requestFrom").queryEqual(toValue: partnerId).observe(.childAdded) { [weak self] (snapshot) in
            guard let self = self else { return }
            mailRef.child(snapshot.key).observeSingleEvent(of: .value) { (snap) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let requestTo = dictionary["requestTo"] as! String
                    if requestTo == uid {
                        self.otherUserSentRequest = true
                        self.otherUser_alreadyRequested_label()
                        self.addButton.isEnabled = true
                        
                        let title = self.stringHelper.generateAttributedString(titleName: "Accept Request", imageName: "checkmark", fontSize: 16)
                        self.addButton.setAttributedTitle(title, for: .normal)
                    }
                }
            }
        }
    }
    
    //MARK:- Lottie Animations
    
    func presentAddedContact() {
        view.addSubview(lottieVC.view)
        lottieVC.view.frame = view.bounds
        lottieVC.view.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.lottieVC.view.alpha = 1
        }) { (completion) in
            self.handleTimer()
        }
    }
    
    func handleTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.6, target: self, selector: #selector(self.removeLottieView), userInfo: nil, repeats: false)
    }
    
    @objc func removeLottieView() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.lottieVC.view.alpha = 0
        }, completion: nil)
    }
}

class StringHelper {
    static let shared = StringHelper()
    
    func generateAttributedString(titleName: String, imageName: String?, fontSize: CGFloat) -> NSMutableAttributedString {
        let fullString = NSMutableAttributedString(string: "")
        if let imageName = imageName {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: imageName)
            imageAttachment.image = imageAttachment.image?.withTintColor(.white, renderingMode: .alwaysOriginal)
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: " "))
        }
        
        fullString.append(NSAttributedString(string: titleName))
        fullString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: .semibold)], range: NSRange(0..<fullString.length))
            
        return fullString
    }
}
