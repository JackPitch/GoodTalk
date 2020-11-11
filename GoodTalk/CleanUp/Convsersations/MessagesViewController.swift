//
//  CustomSearchBar.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/10/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImage

enum Section {
    case main
}

protocol MessagesDelegate: class {
    func didTapGetUser(for user: User)
}

protocol SignInDelegate: class {
    func didSignIn()
}

class MessagesViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, ProfileVCDelegate, ContactsDelegate {
    
    func didTapContact(chatPartnerId: String) {
        let newChatRepresentable = ChatView(observedUser: ObservedUser(chatPartnerId: chatPartnerId), chatPartnerId: chatPartnerId)
        let hostingController = UIHostingController(rootView: newChatRepresentable)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func didTapSignOut() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.messagesViewController = self
        present(loginVC, animated: true)
        messages.removeAll()
        filteredMessages.removeAll()
        updateData(messages: messages, animated: false)
    }
        
    var messages = [Message]()
    var filteredMessages = [Message]()
    var messagesDictionary = [String: Message]()
    var tableView: UITableView!
    var isLogged = false
    var isSearching = false
    var timer: Timer?
    var currentUser = ""
    
    let emptyMailBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "envelope.badge"), style: .plain, target: self, action: #selector(handlePresentRequests))
    
    let mailBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "envelope"), style: .plain, target: self, action: #selector(handlePresentRequests))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        view.backgroundColor = .white
        
        setupSearchBar()
        setupTableView()
        setupDataSource()
        setupContactsButton()
        setupUserSearch()
        
        tableView.separatorColor = .clear
        self.title = "Conversations"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle.fill"), style: .plain, target: self, action: #selector(handleGoToProfile))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "envelope"), style: .plain, target: self, action: #selector(handlePresentRequests))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserHasMail()
    }
        
    func checkIfUserHasMail() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let mailRef = Database.database().reference().child("mail")
        let query = mailRef.queryOrdered(byChild: "requestTo").queryEqual(toValue: uid)
        query.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self = self else { return }
            
            if (snapshot.value as? [String: AnyObject]) != nil {
                self.navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(systemName: "envelope.badge"), style: .plain, target: self, action: #selector(self.handlePresentRequests)), animated: true)

            } else {
                self.navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(systemName: "envelope"), style: .plain, target: self, action: #selector(self.handlePresentRequests)), animated: true)
            }
        }
    }
    
    @objc func handlePresentRequests() {
        let requestsVC = MailViewController()
        navigationController?.pushViewController(requestsVC, animated: true)
    }
    
    func setupTapDismiss() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleDismissKeyboard() {
        view.endEditing(true)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            let loginController = LoginViewController()
            loginController.modalPresentationStyle = .fullScreen
            loginController.messagesViewController = self
            present(loginController, animated: false)
        } else {
            observeUserMessages()
        }
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginViewController()
        loginController.messagesViewController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleGoToProfile() {
        let profileVC = ProfileViewController()
        profileVC.delegate = self
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //MARK:- Search Bar Setup & Delegates
    
    let searchBarTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Name"
        textField.backgroundColor = .clear
        return textField
    }()
    
    let cancelSearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(handleCancelSearch), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancelSearch() {
        searchBarTextField.text = ""
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func setupSearchBar() {
        let hostingController = UIHostingController(rootView: SearchBackground())
        view.addSubview(hostingController.view)
        hostingController.view.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.bounds.width - 120, height: 100)
        hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        view.addSubview(cancelSearchButton)
        cancelSearchButton.anchor(top: nil, left: nil, bottom: nil, right: hostingController.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        cancelSearchButton.centerYAnchor.constraint(equalTo: hostingController.view.centerYAnchor).isActive = true
        cancelSearchButton.isHidden = true
        
        view.addSubview(searchBarTextField)
        searchBarTextField.anchor(top: hostingController.view.topAnchor, left: hostingController.view.leftAnchor, bottom: hostingController.view.bottomAnchor, right: cancelSearchButton.leftAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        searchBarTextField.delegate = self
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        isSearching = true
        cancelSearchButton.isHidden = false
        guard let filter = textField.text else { return }

        if(filter.isEmpty) {
            filteredMessages = messages
        } else {
         filteredMessages = messages.filter {
            $0.toName == currentUser ?
                ($0.fromName?.lowercased().starts(with: filter.lowercased())
                    ?? false) : ($0.toName?.lowercased().starts(with: filter.lowercased()) ?? false)
            }
        }

        updateData(messages: filteredMessages, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isSearching = true
        cancelSearchButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isSearching = false
        cancelSearchButton.isHidden = true
        updateData(messages: messages, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isSearching = true
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        
        cancelSearchButton.isHidden = true
        
        guard let filter = textField.text else { return false }

        if(filter.isEmpty) {
            filteredMessages = messages
        } else {
         filteredMessages = messages.filter {
            $0.toName == currentUser ?
                ($0.fromName?.lowercased().starts(with: filter.lowercased())
                    ?? false) : ($0.toName?.lowercased().starts(with: filter.lowercased()) ?? false)
            }
        }

        updateData(messages: filteredMessages, animated: true)
        
        return true
    }
    
    //MARK:- NSDiffableDataSource
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: "cellID")
        view.addSubview(tableView)
        tableView.anchor(top: searchBarTextField.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    func updateData(messages: [Message], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Message>()
        snapshot.appendSections([.main])
        snapshot.appendItems(messages)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: animated) }
    }

    func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Message>(tableView: tableView, cellProvider: { (tableView, indexPath, message) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! MessageCell
            cell.set(message: message)
            return cell
        })
    }

    var dataSource: UITableViewDiffableDataSource<Section, Message>!

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.resignFirstResponder()
        let message = isSearching ? filteredMessages[indexPath.row] : messages[indexPath.row]
        
        handleCancelSearch()
        
        let newChatRepresentable = ChatView(observedUser: ObservedUser(chatPartnerId: (message.toID == Auth.auth().currentUser?.uid ? message.fromID : message.toID) ?? ""), chatPartnerId: (message.toID == Auth.auth().currentUser?.uid ? message.fromID : message.toID) ?? "")
        let hostingController = UIHostingController(rootView: newChatRepresentable)
        self.tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    
    //MARK:- Present Contacts Button
    
    func setupContactsButton() {
        let hostingController = UIHostingController(rootView: PresentContactsButton())
        view.addSubview(hostingController.view)
        hostingController.view.backgroundColor = .clear
        hostingController.view.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: 20, width: 0, height: 0)
        
        view.addSubview(presentContactsButton)
        presentContactsButton.anchor(top: hostingController.view.topAnchor, left: hostingController.view.leftAnchor, bottom: hostingController.view.bottomAnchor, right: hostingController.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 24, width: 0, height: 0)
    }
    
    let presentContactsButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handlePresentContacts), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePresentContacts() {
        let contactsVC = ContactsPageViewController()
        contactsVC.delegate = self
        let navController = UINavigationController(rootViewController: contactsVC)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
    
    //MARK:- Present Search Button
    
    let userSearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handlePresentSearch), for: .touchUpInside)
        return button
    }()
    
    let presentSearchButton = UIHostingController(rootView: PresentSearchButton())
    
    func setupUserSearch() {
        view.addSubview(presentSearchButton.view)
        presentSearchButton.view.backgroundColor = .clear
        presentSearchButton.view.anchor(top: nil, left: nil, bottom: presentContactsButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 24, width: 0, height: 0)
        view.addSubview(userSearchButton)
        userSearchButton.anchor(top: presentSearchButton.view.topAnchor, left: presentSearchButton.view.leftAnchor, bottom: presentSearchButton.view.bottomAnchor, right: presentSearchButton.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handlePresentSearch() {
        let userSearchVC = UserSearchController()
        userSearchVC.delegate = self
        let navController = UINavigationController(rootViewController: userSearchVC)
        present(navController, animated: true, completion: nil)
    }
    
    //MARK:- Firebase Functions For Getting Messages
    
    func getCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.currentUser = dictionary["name"] as! String
            }
        }
    }
        
    func observeUserMessages() {
        messages.removeAll()
        messagesDictionary.removeAll()
        filteredMessages.removeAll()
        
        getCurrentUser()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in

            let userId = snapshot.key
            
            self.checkIfUserIsInContacts(partnerId: userId)
        })
    }
    
    func checkIfUserIsInContacts(partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid)
        ref.child("Contacts").child(partnerId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                if value == 1 {
                    self.continueFetchingMessages(uid: uid, userId: partnerId)
                }
            }
        })
    }
    
    func continueFetchingMessages(uid: String, userId: String) {
        Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            self.fetchMessageWithMessageId(messageId)
        })
    }

    func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)

        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {

                let message = Message(dictionary: dictionary)

                if let chatPartnerId = message.chatPartnerId() {
                    
                    self.messagesDictionary[chatPartnerId] = message
                }
                self.attemptReloadOfTable()
            }
                        
        }, withCancel: nil)
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
        
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timeStamp!.intValue > message2.timeStamp!.intValue
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        updateData(messages: messages, animated: false)
        
    }
}

struct MessagesVCRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<MessagesVCRepresentable>) -> UIViewController {
        let viewController = MessagesViewController()
        let navController = UINavigationController(rootViewController: viewController)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MessagesVCRepresentable>) {
    }
    
    typealias UIViewControllerType = UIViewController
}

extension MessagesViewController: MessagesDelegate {
    
    func didTapGetUser(for user: User) {
        
        dismiss(animated: true, completion: nil)
        
        let newChatRepresentable = ChatView(observedUser: ObservedUser(chatPartnerId: user.uuid ?? ""), chatPartnerId: user.uuid ?? "")
        let hostingController = UIHostingController(rootView: newChatRepresentable)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.navigationController?.pushViewController(hostingController, animated: true)
        }
    }
}
