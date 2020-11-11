//
//  MailHandler.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 11/5/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

class MailHandler {
    static let shared = MailHandler()
    
    let uid = Auth.auth().currentUser?.uid
    
    func addContact(partnerId: String) {
        guard let uid = uid else { return }
        let usersRef = Database.database().reference().child("users")
        usersRef.child(uid).child("Contacts").child(partnerId).setValue(1)
        usersRef.child(partnerId).child("Contacts").child(uid).setValue(1)
    }
    
    func deleteFromRequests(partnerId: String) {
        guard let uid = uid else { return }
        Database.database().reference().child("mail")
        let mailRef = Database.database().reference().child("mail")
        let query = mailRef.queryOrdered(byChild: "requestTo").queryEqual(toValue: uid)
        query.observeSingleEvent(of: .childAdded) { (snapshot) in
            var keysArray = [String]()
            keysArray.append(snapshot.key)
            for key in keysArray {
                mailRef.child(key).observeSingleEvent(of: .value) { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let requestFrom = dictionary["requestFrom"] as! String
                        if requestFrom == partnerId {
                            mailRef.child(key).removeValue()
                        }
                    }
                }
            }
        }
    }
    
    func deleteFromSentRequests(partnerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("mail")
        let mailRef = Database.database().reference().child("mail")
        let query = mailRef.queryOrdered(byChild: "requestFrom").queryEqual(toValue: uid)
        query.observeSingleEvent(of: .childAdded) { (snapshot) in
            var keysArray = [String]()
            keysArray.append(snapshot.key)
            for key in keysArray {
                mailRef.child(key).observeSingleEvent(of: .value) { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let requestTo = dictionary["requestTo"] as! String
                        if requestTo == partnerId {
                            mailRef.child(key).removeValue()
                        }
                    }
                }
            }
        }
    }
    
    func deleteContact(partnerId: String) {
        guard let uid = uid else { return }
        let ref = Database.database().reference().child("users")
        ref.child(uid).child("Contacts").child(partnerId).removeValue()
        ref.child(partnerId).child("Contacts").child(uid).removeValue()
    }
}
