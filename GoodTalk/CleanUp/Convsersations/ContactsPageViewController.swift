//
//  ContactsPageViewController.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 9/21/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

protocol ContactsDelegate: class {
    func didTapContact(chatPartnerId: String)
}

class ContactsPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ContactInfoPageDelegate {
    
    var tableView: UITableView!
    
    var delegate: ContactsDelegate!
    
    var contacts = [User]()
                    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        getContacts()
    }
    
    func deleteContact(user: User) {
        //remove contact from firebase
        guard let userId = user.uuid else { return }
        
        MailHandler.shared.deleteContact(partnerId: userId)
        
        guard let index = self.contacts.firstIndex(of: user) else { return }
        let indexToDelete = IndexPath(row: index, section: 0)
        
        self.contacts.removeAll { contact in
            contact == user
        }
        
        self.tableView.deleteRows(at: [indexToDelete], with: .automatic)
        

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "xmark.circle.fill"), style: .done, target: self, action: #selector(handleDone))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.7058823529, blue: 0.2, alpha: 1)
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationController?.navigationBar.prefersLargeTitles = true
            title = "Contacts"
        } else {
            navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.7058823529, blue: 0.2, alpha: 1)
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ContactCell.self, forCellReuseIdentifier: "cellID")
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! ContactCell
        cell.accessoryType = .detailDisclosureButton
        cell.tintColor = .systemGray
        let user = contacts[indexPath.row]
        cell.infoButton.tag = indexPath.row
        cell.set(user: user, userInfoEnabled: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let user = contacts[indexPath.row]
        let contactInfoPage = ContactInfoPage()
        contactInfoPage.delegate = self
        contactInfoPage.user = user
        navigationController?.pushViewController(contactInfoPage, animated: true)
    }
    
    @objc func handleDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func getContacts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let usersRef = Database.database().reference().child("users")
        usersRef.child(uid).child("Contacts").observe(.childAdded) { [weak self] (snapshot) in
            guard let self = self else { return }
            usersRef.child(snapshot.key).observeSingleEvent(of: .value) { (snap) in
                if let dict = snap.value as? [String: AnyObject] {
                    var user = User(dictionary: dict)
                    user.uuid = snapshot.key
                    self.contacts.append(user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatParnterId = contacts[indexPath.row].uuid else { return }
        dismiss(animated: true) {
            self.delegate.didTapContact(chatPartnerId: chatParnterId)
        }
    }
}
