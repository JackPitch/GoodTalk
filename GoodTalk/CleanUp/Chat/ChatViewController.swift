//
//  TestViewController.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/1/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

class ChatViewController: UITableViewController {
    
    var messages = [Message]()
    
    var lastIndex: Int = 0
    
    var chatPartnerId: String? {
        didSet {
            getMessages()
        }
    }
    
    var user: User?
    var textMessage: String = ""
    var height: CGFloat = 80
    
    let cache = NSCache<NSString, NSArray>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelection = false
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "cellID")
        tableView.separatorStyle = .none
        navigationController?.navigationBar.isHidden = false
    }
    
    func getMessages() {
        if let messages = self.cache.object(forKey: "chatMessages") as? [Message] {
            self.messages = messages
            print("got the chat cache!")
        } else {
            self.observeMessages()
        }
    }
    
    func setupChatBar() {
        let chatBar = ChatBarView(textMessage: self.textMessage, height: height, observedUser: ObservedUser(chatPartnerId: chatPartnerId ?? ""))
        let searchBarController = UIHostingController(rootView: chatBar)
        addChild(searchBarController)
        view.addSubview(searchBarController.view)
        searchBarController.didMove(toParent: self)
        searchBarController.view.anchor(top: view.centerYAnchor, left: nil, bottom: nil, right: nil, paddingTop: view.frame.width / 2, paddingLeft: 0, paddingBottom: 12, paddingRight: 20, width: 0, height: 0)
        
        searchBarController.view.backgroundColor = .clear
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.invalidateIntrinsicContentSize()
    }
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! ChatMessageCell
        cell.set(message: message)
        return cell
    }
    
    func observeMessages() {
        if let chatPartnerId = chatPartnerId {
            Database.database().reference().child("users").child(chatPartnerId).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    var user = User(dictionary: dictionary)
                    user.uuid = snapshot.key
                    self.user = user
                    
                    guard let currentUser = Auth.auth().currentUser?.uid else { return }
                    if let otherId = self.user?.uuid {
                        let userMessagesRef = Database.database().reference().child("user-messages").child(currentUser).child(otherId)
                        
                        userMessagesRef.observe(.childAdded, with: { (userSnapshot) in
                            
                            let messageId = userSnapshot.key
                            let messagesRef = Database.database().reference().child("messages").child(messageId)
                            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let dictionary = snapshot.value as? [String : AnyObject] {
                                    let message = Message(dictionary: dictionary)
                                    //self.messages.insert(message, at: 0)
                                    self.messages.append(message)
                                    self.lastIndex = self.messages.count
                                    self.cache.setObject(self.messages as NSArray, forKey: "chatMessages")
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                    print("chat cache set!")
                                }
                            }, withCancel: nil)
                        }, withCancel: nil)
                    }
                }
            }
        }
    }
}



struct ChatBarView: View {
    @State var textMessage: String
    @State var height: CGFloat = 80
    @ObservedObject var observedUser: ObservedUser
    
    var body: some View {
        HStack(alignment: .bottom) {
                ResizableTextField(text: $textMessage, height: $height)
                    .frame(width: screen.width - 120, height: self.height)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
                Spacer()
                Button(action: {
                    self.sendMessage()
                }) {
                    Text("Send")
                        .bold()
                        .foregroundColor(self.textMessage.count == 0 ? .gray : .white)
                        .frame(width: 75, height: 60)
                        .background(self.textMessage.count == 0 ? Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)) : Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
                        .cornerRadius(22)
                        .shadow(color: self.textMessage.count == 0 ? Color.black.opacity(0.2) : Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)).opacity(0.4), radius: 12, x: 0, y: 8)
                }
                .disabled(self.textMessage.count == 0)
            }
            .padding()
            .padding(.bottom)
    }
    
    func sendMessage() {
        var fromName = ""
        Database.database().reference().child("users").child(Auth.auth().currentUser?.uid ?? "").observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                fromName = dictionary["name"] as! String
            }
        }
        
        print("fromName: ", fromName)
        
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = observedUser.user?.uuid ?? ""
        let toName = observedUser.user?.name ?? ""
        let fromID = Auth.auth().currentUser!.uid
        let timeStamp = Int(Date().timeIntervalSince1970)
        let values = ["textMessage": textMessage, "toID": toID, "toName": toName, "fromID": fromID, "timeStamp": timeStamp, "fromName": fromName] as [String : Any]
        print(values)
        childRef.updateChildValues(values) { (err, ref) in
            if let err = err {
                print(err)
                return
            }
            guard let messageId = childRef.key else { return }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromID).child(toID).child(messageId)
            userMessagesRef.setValue(1)

            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID).child(fromID).child(messageId)
            recipientUserMessagesRef.setValue(1)
        }
        self.textMessage = ""
        UIApplication.shared.endEditing()
    }
}
