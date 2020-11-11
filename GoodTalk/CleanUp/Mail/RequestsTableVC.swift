//
//  RequestsTableVC.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 9/19/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

protocol RequestDelegate: class {
    func didTapDelete(user: User)
    func didTapAccept(user: User)
}

class RequestsTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var lottieCard = UIHostingController(rootView: LottieCard(animationMessage: "Contact Added!"))
    
    var timer: Timer?
    
    var requests = [User]()
    
    var tableView: UITableView!
        
    let noMailView = UIHostingController(rootView: NoMailView(message: "No Requests"))
    
    let mailHandler = MailHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addEmptyView()
        getRequests()
    }
    
    #warning("upload new code base to github")
        
    func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.allowsSelection = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RequestsCell.self, forCellReuseIdentifier: "cellID")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! RequestsCell
        let user = requests[indexPath.item]
        cell.profileLabel.text = user.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = requests[indexPath.row]
        let statusPopOver = StatusPopOver()
        statusPopOver.delegate = self
        statusPopOver.modalPresentationStyle = .overFullScreen
        statusPopOver.modalTransitionStyle = .crossDissolve
        statusPopOver.user = user
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.window?.rootViewController?.present(statusPopOver, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func addEmptyView() {
        view.addSubview(noMailView.view)
        noMailView.view.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func getRequests() {
        var keysArray = [String]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let mailRef = Database.database().reference().child("mail")
        let query = mailRef.queryOrdered(byChild: "requestTo").queryEqual(toValue: uid)
        query.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            if let dictionary = snapshot.value as? [String: Any] {

                keysArray.append(contentsOf: dictionary.keys)
                for key in keysArray {
                    mailRef.child(key).observeSingleEvent(of: .value) { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let requestFrom = dictionary["requestFrom"] as! String
                            let requestTo = dictionary["requestTo"] as! String
                            
                            if(requestTo == uid) {
                                self.getUsersFromMail(uid: requestFrom)
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
                self.requests.append(user)
                DispatchQueue.main.async {
                    self.view.bringSubviewToFront(self.tableView)
                    self.tableView.reloadData()
                }
            }
        }
    }
        
    func deleteMail(user: User) {
        guard let userId = user.uuid else { return }
        
        MailHandler.shared.deleteFromRequests(partnerId: userId)
        
        guard let index = self.requests.firstIndex(of: user) else { return }
        let indexToDelete = IndexPath(row: index, section: 0)
        
        self.requests.removeAll { contact in
            contact == user
        }
        
        self.tableView.deleteRows(at: [indexToDelete], with: .automatic)
        

        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.requests.isEmpty {
                self.view.bringSubviewToFront(self.noMailView.view)
            }
        }
    }
}

//MARK:- Handle Accept / Delete Request

extension RequestsTableVC: RequestDelegate {
    
    func didTapAccept(user: User) {
        guard let partnerId = user.uuid else { return }
        addContact(partnerId: partnerId, user: user)
        presentAddedContact()
    }
    
    func didTapDelete(user: User) {
        self.deleteMail(user: user)
    }
    
    func addContact(partnerId: String, user: User) {
        mailHandler.addContact(partnerId: partnerId)
        
        deleteMail(user: user)
    }
    
    func presentAddedContact() {
        lottieCard.modalPresentationStyle = .overFullScreen
        lottieCard.modalTransitionStyle = .crossDissolve
        present(lottieCard, animated: true)
        handleTimer()
    }
    
    func handleTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.6, target: self, selector: #selector(self.removeLottieView), userInfo: nil, repeats: false)
    }
    
    @objc func removeLottieView() {
        lottieCard.dismiss(animated: true, completion: nil)
    }
}
