//
//  NewChatView.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/1/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

struct ChatView: View {
    @ObservedObject var observedUser: ObservedUser
    @State var chatPartnerId: String
    @State var textMessage: String = ""
    @State var height: CGFloat = 80
    @State var value: CGFloat = 0
    @State var didSendMessage: Bool = false
    @State var image = UIImage()
    @State var showImagePicker = false

    var body: some View {
        ZStack {
            VStack {
                ChatRepresentable(chatPartnerId: chatPartnerId)
                    .padding(.horizontal, 8)
                    .offset(x: 0, y: -self.value / 1.0)
                    .animation(.spring())
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 50, height: screen.width / 6)
                    .foregroundColor(.clear)
            }
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Button(action: {
                        self.showImagePicker.toggle()
                    }) {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .foregroundColor(Color(.systemGray3))
                            .frame(width: 40, height: 40)
                            .aspectRatio(contentMode: .fit)
                    }
                    ResizableTextField(text: $textMessage, height: $height)
                        .frame(width: screen.width - 180, height: self.height)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
                    Button(action: {
                        self.sendMessage()
                        self.didSendMessage = true
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
                    .offset(x: 0, y: -self.value / 1.1)
                    .animation(.spring())
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                let height = value.height
                self.value = height
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                self.value = 0
                self.textMessage = ""
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .navigationBarTitle(Text(observedUser.user?.name ?? "no name"), displayMode: .inline)
        .sheet(isPresented: $showImagePicker) {
            PhotoUploadButton(showPicker: self.$showImagePicker, image: self.$image, toID: self.observedUser.user?.uuid ?? "", textMessage: self.$textMessage)
        }
    }
    
    func sendMessage() {
        var fromName = ""
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = observedUser.user?.uuid ?? ""
        let toName = observedUser.user?.name ?? ""
        let fromID = Auth.auth().currentUser!.uid
        let timeStamp = Int(Date().timeIntervalSince1970)

        Database.database().reference().child("users").child(fromID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                fromName = dictionary["name"] as! String
                
                let values = ["textMessage": self.textMessage, "toID": toID, "toName": toName, "fromID": fromID, "timeStamp": timeStamp, "fromName": fromName] as [String : Any]
                
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
    }
}
