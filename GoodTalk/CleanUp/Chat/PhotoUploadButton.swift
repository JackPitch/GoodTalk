//
//  ImagePickerRepresentable.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 5/31/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

struct PhotoUploadButton: UIViewControllerRepresentable {
    @Binding var showPicker: Bool
    @Binding var image: UIImage
    @State var toID: String
    @Binding var textMessage: String
    
    
    typealias UIViewControllerType = UIViewController
    

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        //MARK:- Image Selector & Coordinator

        let parent: PhotoUploadButton
        
        init(parent: PhotoUploadButton) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let selectedImageFromPicker = info[.editedImage] as? UIImage {
                self.parent.image = selectedImageFromPicker
                
                uploadToFirebaseStorageUsingImage(selectedImageFromPicker) { (imageUrl) in
                    self.sendMessageWithImageUrl(imageUrl, image: selectedImageFromPicker)
                }
                
            } else if let selectedImageFromPicker = info[.originalImage] as? UIImage {
                self.parent.image = selectedImageFromPicker
                
                uploadToFirebaseStorageUsingImage(selectedImageFromPicker) { (imageUrl) in
                    self.sendMessageWithImageUrl(imageUrl, image: selectedImageFromPicker)
                }
            }
            
            self.parent.showPicker.toggle()
        }
        
        //MARK:- Upload Image To Firebase
        
        fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
            let imageName = UUID().uuidString
            let ref = Storage.storage().reference().child("message_images").child(imageName)
            
            if let uploadData = image.jpegData(compressionQuality: 0.2) {
                ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print("Failed to upload image:", error!)
                        return
                    }
                    
                    ref.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        
                        completion(url?.absoluteString ?? "")
                    })
                    
                })
            }
        }
        
        fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
            let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
            sendMessageWithProperties(properties)
            print(properties)
        }
        
        fileprivate func sendMessageWithProperties(_ properties: [String: Any]) {
            let ref = Database.database().reference().child("messages")
            let childRef = ref.childByAutoId()
            let toID = parent.toID
            let fromID = Auth.auth().currentUser!.uid
            let timeStamp = Int(Date().timeIntervalSince1970)
            
            let usersRef = Database.database().reference().child("users")
            
            usersRef.child(fromID).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let fromName = dictionary["name"] as! String
                    
                    usersRef.child(toID).observeSingleEvent(of: .value) { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let toName = dictionary["name"] as! String
                            
                            var values = ["textMessage": self.parent.textMessage, "toID": toID, "toName": toName, "fromID": fromID, "timeStamp": timeStamp, "fromName": fromName] as [String : Any]
                            
                            print(values)
                            
                            properties.forEach({values[$0] = $1})
                            
                            childRef.updateChildValues(values) { (error, ref) in
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                            
                                guard let messageId = childRef.key else { return }
                                
                                let userMessagesRef = Database.database().reference().child("user-messages").child(fromID).child(toID).child(messageId)
                                userMessagesRef.setValue(1)
                                
                                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID).child(fromID).child(messageId)
                                recipientUserMessagesRef.setValue(1)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> PhotoUploadButton.Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoUploadButton>) -> UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PhotoUploadButton.UIViewControllerType, context: UIViewControllerRepresentableContext<PhotoUploadButton>) {
    }
}


