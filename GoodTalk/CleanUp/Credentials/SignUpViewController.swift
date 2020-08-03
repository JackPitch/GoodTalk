//
//  SignInViewController.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/16/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

protocol SignUpDelegate: class {
    func didCreateUser()
}

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    weak var delegate: SignUpDelegate!

    let successVC = SuccessViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = .white
        imagePicker.delegate = self

        title = "Create Account"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleGoToLogin))

        setupProfileImage()
        setupBackgrounds()
        setupCredentialsForm()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height / 3)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    //MARK:- Profile Image Setup & Picker

    let segmentedCircle = UIHostingController(rootView: SegmentedCircle())
    let imagePicker = UIImagePickerController()

    func setupProfileImage() {
        view.addSubview(segmentedCircle.view)
        segmentedCircle.view.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 85, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        segmentedCircle.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(chosenImageView)
        chosenImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 80, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 180, height: 180)
        chosenImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(imagePickerButton)
        imagePickerButton.anchor(top: segmentedCircle.view.topAnchor, left: segmentedCircle.view.leftAnchor, bottom: segmentedCircle.view.bottomAnchor, right: segmentedCircle.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    let imagePickerBackground: UIView = {
        let view = UIView()
        let circle = UIHostingController(rootView: SegmentedCircle())
        view.addSubview(circle.view)
        return view
    }()

    let chosenImageView: UIImageView = {
        let chosenImage = UIImageView()
        chosenImage.image = UIImage()
        chosenImage.clipsToBounds = true
        chosenImage.layer.cornerRadius = 90
        return chosenImage
    }()

    let imagePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleImagePicker), for: .touchUpInside)
        return button
    }()

    @objc func handleImagePicker() {
        print("present image picker")
        present(imagePicker, animated: true)
        self.nameSection.textField.endEditing(true)
        self.emailSection.textField.endEditing(true)
        self.passwordSection.textField.endEditing(true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImageView.contentMode = .scaleAspectFill
            chosenImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    //MARK:- TextField & Background Setup

    let nameSection = TextSection(imageName: "person.fill", textName: "Name:")
    let emailSection = TextSection(imageName: "envelope.fill", textName: "Email:")
    let passwordSection = TextSection(imageName: "lock.fill", textName: "Password:")
    let signUpCard = UIHostingController(rootView: SignUpCard())
    let background = UIHostingController(rootView: SignUpBackgroundView())

    func setupBackgrounds() {
        view.addSubview(background.view)
        background.view.backgroundColor = .clear
        background.view.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 0)

        view.addSubview(signUpCard.view)
        signUpCard.view.backgroundColor = .clear
        signUpCard.view.anchor(top: background.view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        signUpCard.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func setupCredentialsForm() {
        let createButtonView = UIHostingController(rootView: CreateButtonView())
        view.addSubview(createButtonView.view)
        createButtonView.view.backgroundColor = .clear
        createButtonView.view.anchor(top: signUpCard.view.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        createButtonView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(createButton)
        createButton.anchor(top: createButtonView.view.topAnchor, left: createButtonView.view.leftAnchor, bottom: createButtonView.view.bottomAnchor, right: createButtonView.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        view.addSubview(nameSection)
        nameSection.anchor(top: signUpCard.view.topAnchor, left: signUpCard.view.leftAnchor, bottom: nil, right: signUpCard.view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        nameSection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(emailSection)
        emailSection.anchor(top: nameSection.bottomAnchor, left: signUpCard.view.leftAnchor, bottom: nil, right: signUpCard.view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        emailSection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(passwordSection)
        passwordSection.anchor(top: emailSection.bottomAnchor, left: signUpCard.view.leftAnchor, bottom: nil, right: signUpCard.view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        passwordSection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    @objc func handleGoToLogin() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func handleCreateAccount() {

        nameSection.textField.resignFirstResponder()
        emailSection.textField.resignFirstResponder()
        passwordSection.textField.resignFirstResponder()

        guard let email = emailSection.textField.text else { return }
        guard let password = passwordSection.textField.text else { return }
        guard let name = nameSection.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        let totalCount = email.count + password.count + name.count
        
        if(totalCount == 0) {
            self.presentAlert(message: "Please Fill Empty Form")
        } else if (name.count < 3) {
            self.presentAlert(message: "Name Must Be At Least 3 Characters")
        } else {
            registerToFirebase(userEmail: email, userPassword: password, username: name)
        }
    }

    let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleCreateAccount), for: .touchUpInside)
        return button
    }()

    //MARK:- Create User via Firebase
    
    private func registerToFirebase(userEmail: String, userPassword: String, username: String) {
        
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (result, err) in
            if let err = err {
                print("error creating user", err)
                self.presentAlert(message: err.localizedDescription)
                return
            }
            
            self.successVC.modalPresentationStyle = .overFullScreen
            self.successVC.modalTransitionStyle = .crossDissolve
            self.present(self.successVC, animated: true)

            guard let uid = result?.user.uid else { return }

            if self.chosenImageView.image != UIImage() {
                if let imageData = self.chosenImageView.image?.jpegData(compressionQuality: 0.1) {

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

                            let values = ["name": username, "email": userEmail, "imageUrl": profileImageUrl]
                            
                            self.registerToDatabase(uid: uid, values: values)
                        }
                    }
                }
            } else {
                print("no image selected")
                
                let values = ["name": username, "email": userEmail, "imageUrl": ""]
                
                self.registerToDatabase(uid: uid, values: values)
            }
        }
    }

    private func registerToDatabase(uid: String, values: [String: String]) {
        let ref = Database.database().reference(fromURL: "https://goodtalk-bed82.firebaseio.com/")

        let usersRef = ref.child("users").child(uid)

        usersRef.updateChildValues(values) { (err, ref) in

            if let err = err {
                print("error updating values", err)
                return
            }
        }
        
        self.successVC.dismiss(animated: true) {
            self.dismiss(animated: true) {
                self.delegate.didCreateUser()
            }
        }
    }
}

    //MARK:- SwiftUI View Helpers

struct SegmentedCircle: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .miter, miterLimit: 0, dash: [14, 14]))
                .frame(width: 170, height: 170)
                .foregroundColor(Color(#colorLiteral(red: 0.6028467466, green: 0.7640999572, blue: 1, alpha: 1)))
            VStack {
                Image(systemName: "plus")
                .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color(#colorLiteral(red: 0.6028467466, green: 0.7640999572, blue: 1, alpha: 1)))
                    .frame(width: 20, height: 20)
                Text("Add Photo")
                .foregroundColor(Color(#colorLiteral(red: 0.6028467466, green: 0.7640999572, blue: 1, alpha: 1)))
            }
        }
    }
}

struct IconView: View {
    @State var named: String = "person.fill"

    var body: some View {
        Image(systemName: named)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 15, height: 15)
        .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
        .background(
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
        )
    }
}

struct SignUpBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .frame(width: screen.width - 20, height: screen.height * 0.55)
            .foregroundColor(.white)
            .shadow(radius: 22)
    }
}

struct SignUpCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
            .frame(width: screen.width - 60, height: screen.height * 0.3)
            .shadow(color: Color.black.opacity(0.15), radius: 22, x: 0, y: 0)
    }
}

struct CreateButtonView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
            .frame(width: screen.width / 2, height: 50)
            .shadow(color: Color.black.opacity(0.2), radius: 22, x: 0, y: 12)
    }
}
