//
//  SentRequestsTableVC.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 9/19/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

class SentRequestsTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var timer: Timer?
    
    var sentRequests = [User]()
    
    var tableView: UITableView!
        
    let noMailView = UIHostingController(rootView: NoMailView(message: "No Sent Requests"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addEmptyView()
        getMail()
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(handleReloadTableView), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTableView() {
        self.tableView.reloadData()
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.allowsSelection = false
        tableView.register(SentRequestsCell.self, forCellReuseIdentifier: "cellID")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func addEmptyView() {
        view.addSubview(noMailView.view)
        noMailView.view.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func checkIsEmpty() {
        sentRequests.isEmpty ? view.bringSubviewToFront(noMailView.view) : view.bringSubviewToFront(tableView)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! SentRequestsCell
        let user = sentRequests[indexPath.row]
        cell.profileLabel.text = user.name
        cell.emailLabel.text = user.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let user = sentRequests[indexPath.row]
        if editingStyle == .delete {
            self.deleteMail(user: user)
        }
    }
    
    func deleteFromFirebase(indexPath: IndexPath, name: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users")
        ref.child(uid).child("Mail").observe(.childAdded) { [weak self] (snapshot) in
            guard let self = self else { return }
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let requestTo = dictionary["requestTo"] as! String
                if(requestTo != uid) {
                    ref.child(requestTo).observe(.value) { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let otherName = dictionary["name"] as! String
                            if name == otherName {
                                var user = self.sentRequests[indexPath.row]
                                user.uuid = snapshot.key
                                self.deleteMail(user: user)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteMail(user: User) {
        guard let userId = user.uuid else { return }
        
        MailHandler.shared.deleteFromSentRequests(partnerId: userId)
        
        guard let index = self.sentRequests.firstIndex(of: user) else { return }
        let indexToDelete = IndexPath(row: index, section: 0)
        
        self.sentRequests.removeAll { contact in
            contact == user
        }
        
        self.tableView.deleteRows(at: [indexToDelete], with: .automatic)

        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.sentRequests.isEmpty {
                self.view.bringSubviewToFront(self.noMailView.view)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sentRequests.count
    }
    
    func getSentRequests() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(currentUser).child("Mail").observe(.childAdded) { [weak self] (snapshot) in
            guard let self = self else { return }
            
            if let dictionary = snapshot.value as? [String: Any] {
                let requestTo = dictionary["requestTo"] as! String
                
                if requestTo != currentUser {
                    Database.database().reference().child("users").child(requestTo).observeSingleEvent(of: .value) { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let user = User(dictionary: dictionary)
                            self.view.bringSubviewToFront(self.tableView)
                            DispatchQueue.main.async {
                                self.sentRequests.append(user)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK:- new mail node system
    
    func getMail() {
        var keysArray = [String]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let mailRef = Database.database().reference().child("mail")
        let query = mailRef.queryOrdered(byChild: "requestFrom").queryEqual(toValue: uid)
        query.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            if let dictionary = snapshot.value as? [String: Any] {

                keysArray.append(contentsOf: dictionary.keys)
                for key in keysArray {
                    mailRef.child(key).observeSingleEvent(of: .value) { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let requestFrom = dictionary["requestFrom"] as! String
                            let requestTo = dictionary["requestTo"] as! String
                            
                            if(requestFrom == uid) {
                                self.getUsersFromMail(uid: requestTo)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUsersFromMail(uid: String) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            if let dictionary = snapshot.value as? [String: AnyObject] {
                var user = User(dictionary: dictionary)
                user.uuid = snapshot.key
                self.sentRequests.append(user)
                DispatchQueue.main.async {
                    self.view.bringSubviewToFront(self.tableView)
                    self.attemptReloadOfTable()
                }
            }
        }
    }
}
