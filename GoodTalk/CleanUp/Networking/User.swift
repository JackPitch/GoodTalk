//
//  Extension.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 6/1/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

struct User: Hashable, Identifiable {
        var uuid: String?
        var id = UUID()
        var email: String?
        var imageUrl: String?
        var name: String?
    
    init() {
       self.uuid = ""
       self.name = ""
       self.imageUrl = "profile"
    }

    init(dictionary: [String: AnyObject]) {
        self.email = dictionary["email"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.name = dictionary["name"] as? String
    }
}

class UserStore: ObservableObject {
    @Published var users: [User] = []
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
        
        let ref = Database.database().reference().child("users")
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                var user = User(dictionary: dictionary)
                user.uuid = snapshot.key
                DispatchQueue.main.async {
                    self.users.append(user)
                }
            }
            
        }, withCancel: nil)
    }
}

class ObservedUser: ObservableObject {
    @Published var user: User?
    @Published var messages = [Message]()
        
    init(chatPartnerId: String) {
        if(chatPartnerId != "") {
            Database.database().reference().child("users").child(chatPartnerId).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    var user = User(dictionary: dictionary)
                    user.uuid = snapshot.key
                    self.user = user
                }
            }
        }
    }
}

