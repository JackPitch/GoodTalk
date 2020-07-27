//
//  MessageModel.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 6/16/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

struct Message: Hashable, Identifiable {
    var id = UUID()
    var textMessage: String?
    var fromID: String?
    var toID: String?
    var toName: String?
    var fromName: String?
    var timeStamp: NSNumber?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var imageUrl: String?
    
    init(dictionary: [String : AnyObject]) {
        self.fromName = dictionary["fromName"] as? String
        self.textMessage = dictionary["textMessage"] as? String
        self.fromID = dictionary["fromID"] as? String
        self.toID = dictionary["toID"] as? String
        self.toName = dictionary["toName"] as? String
        self.timeStamp = dictionary["timeStamp"] as? NSNumber
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
    init() {
        self.textMessage = ""
        self.fromID = ""
        self.toID = ""
    }
    
    func chatPartnerId() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
}
