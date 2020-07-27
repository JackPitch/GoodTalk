//
//  ProfileViewController.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/12/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

//fix image picker bug

protocol ProfileVCDelegate: class {
    func didTapSignOut()
}

class ProfileViewController: UIViewController {
    
    weak var delegate: ProfileVCDelegate!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        getCurrentUser()
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: screen.width / 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupImagePicker()

        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: imagePicker.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupSignOutButton()
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle")
        iv.tintColor = .black
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 75
        return iv
    }()
    
    let imagePicker: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleImagePicker), for: .touchUpInside)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        return button
    }()
    
    func setupImagePicker() {
        let hostingController = UIHostingController(rootView: ShowImageButton())
        view.addSubview(hostingController.view)
        hostingController.view.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(imagePicker)
        imagePicker.anchor(top: hostingController.view.topAnchor, left: hostingController.view.leftAnchor, bottom: hostingController.view.bottomAnchor, right: hostingController.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupSignOutButton() {
        let hostingController = UIHostingController(rootView: SignOutButtonView())
        view.addSubview(hostingController.view)
        hostingController.view.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: screen.width / 4, paddingRight: 0, width: 0, height: 0)
        hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(signOutButton)
        signOutButton.anchor(top: hostingController.view.topAnchor, left: hostingController.view.leftAnchor, bottom: hostingController.view.bottomAnchor, right: hostingController.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleImagePicker() {
        print("present image picker")
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func getCurrentUser() {
        if let image = imageCache.object(forKey: "profileImage") {
            self.profileImageView.image = image
        } else {
            Database.database().reference().child("users").child(Auth.auth().currentUser?.uid ?? "").observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    guard let imageUrl = URL(string: user.imageUrl ?? "") else { return }
                    
                    DispatchQueue.main.async {
                        self.profileImageView.sd_setImage(with: imageUrl)
                        self.usernameLabel.text = user.name
                    }
                    
                    self.getData(from: imageUrl) { (data, _, err) in
                        if let err = err {
                            print("error getting image info, see profileVC", err)
                            return
                        }
                        
                        guard let data = data else { return }
                        
                        if let downloadedImage = UIImage(data: data) {
                            self.imageCache.setObject(downloadedImage, forKey: "profileImage")
                        }
                    }
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @objc func handleSignOut() {
        try? Auth.auth().signOut()
        navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
        delegate.didTapSignOut()
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            self.profileImageView.image = selectedImage
            
            guard let currentUser = Auth.auth().currentUser?.uid else { return }
            
            let userRef = Database.database().reference().child("users").child(currentUser)
            
            if let imageData = selectedImage.pngData() {
            
                let imageUUID = UUID().uuidString
            
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageUUID).png")
            
                storageRef.putData(imageData, metadata: nil) { (metadata, err) in
                    if let err = err {
                        print("error uploadig image to firebase", err)
                        return
                    }
            
                    storageRef.downloadURL { (url, err) in
                        guard let profileImageUrl = url?.absoluteString else {
                            print("error getting downloadUrl", err as Any)
                            return
                        }
                        
                        userRef.observeSingleEvent(of: .value) { (snapshot) in
                            if let dictionary = snapshot.value as? [String: AnyObject] {
                                let values = ["name": dictionary["name"] as! String, "email": dictionary["email"] as! String, "imageUrl": profileImageUrl]
                                
                                registerToDatabase(uid: currentUser, values: values)
                            }
                        }
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

private func registerToDatabase(uid: String, values: [String: String]) {
    let ref = Database.database().reference(fromURL: "https://good-talk-640a0.firebaseio.com/")

    let usersRef = ref.child("users").child(uid)

    usersRef.updateChildValues(values) { (err, ref) in
        
        if let err = err {
            print("error updating values", err)
            return
        }
        
        print("success updating user info!")
    }
}

struct ProfileViewSheet: View {
    
    var body: some View {
        VStack(spacing: screen.width / 2.2) {
            VStack(spacing: 70) {
                VStack(spacing: 12) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .background(Color.white)
                    
                    ShowImageButton()
                    
                    Button(action: {
                        print("get new profile image")
                    }) {
                        Text("Set Photo")
                    }
                }
                
                Text("Username")
                    .font(.system(size: 36, weight: .bold, design: .default))
            }
            
            SignOutButtonView()
        }
    }
}



struct ShowImageButton: View {
    var body: some View {
        Image(systemName: "gear")
            .resizable()
            .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
            .frame(width: 30, height: 30)
            .frame(width: 50, height: 50)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(radius: 22)
    }
}

struct SignOutButtonView: View {
    var body: some View {
        Text("Sign Out")
            .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
            .bold()
            .frame(width: 100, height: 50)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 22, x: 0, y: 12)
    }
}
