//
//  UserSearchController.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/11/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase


class UserSearchController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    var users = [User]()
    var filteredUsers = [User]()
    var timer: Timer?
    
    let hostingController = UIHostingController(rootView: EmptySearchView())
    
    weak var delegate: MessagesDelegate!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "Search"
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(handleDismiss))
        setupSearchBar()
        setupTableView()
        setupDataSource()
        getUsers()
    }
    
    //MARK:- Table View Setup & Data Source
    
    var tableView: UITableView!
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        view.addSubview(tableView)
        tableView.backgroundColor = .white
        tableView.anchor(top: searchBarTextField.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        tableView.delegate = self
        tableView.register(ContactCell.self, forCellReuseIdentifier: "cellID")
        
        view.addSubview(hostingController.view)
        hostingController.view.anchor(top: searchBarTextField.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    var dataSource: UITableViewDiffableDataSource<Section, User>!
    
    func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, User>(tableView: tableView, cellProvider: { (tableView, indexPath, user) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! ContactCell
            cell.set(user: user, userInfoEnabled: false)
            return cell
        })
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func updateData(users: [User], animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filteredUsers, toSection: .main)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: animated) }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        
        let profilePage = UserProfilePageViewController()
        profilePage.didTapUser(user: user)
        navigationController?.pushViewController(profilePage, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getUsers() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                if(Auth.auth().currentUser?.uid != snapshot.key) {
                    var user = User(dictionary: dictionary)
                    user.uuid = snapshot.key
                    self.users.append(user)
                }
            }
            self.attemptReloadOfTable()
        }
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
        
    @objc func handleReloadTable() {
        self.updateData(users: self.users, animated: false)
    }
    
    //MARK:- Search Bar Setup & Delegates
    
    let searchBarTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search Email"
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
        hostingController.view.alpha = 1
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func setupSearchBar() {
        let hostingController = UIHostingController(rootView: SearchBackground(shadowPadding: 16, searchColor: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), glassColor: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))))
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
        hostingController.view.alpha = 0
        cancelSearchButton.isHidden = false
        guard let filter = textField.text else { return }

        if(filter.isEmpty) {
            filteredUsers = [User]()
        } else {
            filteredUsers = users.filter { ($0.email?.lowercased().starts(with: filter.lowercased()) ?? false) }
        }

        updateData(users: filteredUsers, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hostingController.view.alpha = 0
        cancelSearchButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.text?.count == 0) {
            hostingController.view.alpha = 1
        }
        cancelSearchButton.isHidden = true
        updateData(users: filteredUsers, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hostingController.view.alpha = 0
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        
        cancelSearchButton.isHidden = true
        
        guard let filter = textField.text else { return false }

        if(filter.isEmpty) {
            filteredUsers = [User]()
        } else {
            filteredUsers = users.filter { ($0.email?.lowercased().starts(with: filter.lowercased()) ?? false) }
        }

        updateData(users: filteredUsers, animated: true)
        
        return false
    }
}
