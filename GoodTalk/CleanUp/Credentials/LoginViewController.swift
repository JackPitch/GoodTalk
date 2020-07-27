//
//  LoginVc.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/14/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

var screen = UIScreen.main.bounds

class LoginViewController: UIViewController, SignUpDelegate {
    
    var messagesViewController: MessagesViewController?
        
    func didCreateUser() {
        self.messagesViewController?.observeUserMessages()
        self.dismiss(animated: true, completion: nil)
    }
    
    weak var delegate: SignInDelegate!
    
    let loginButtonView = UIHostingController(rootView: LoginButton())
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        setupBackground()
        setupTextFields()
        setupLoginButton()
        
        emailTextField.textContentType = .init(rawValue: "")
        passwordTextField.textContentType = .init(rawValue: "")
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK:- Background Setup

    func setupBackground() {
        view.addSubview(background)
        background.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: screen.height * 0.8)
        
        view.addSubview(background2)
        background2.anchor(top: view.centerYAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(background3)
        background3.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: screen.height * 0.78)
        
        let logo = UIHostingController(rootView: LogoView())
        view.addSubview(logo.view)
        logo.view.anchor(top: nil, left: nil, bottom: background.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        logo.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        view.layer.cornerRadius = 60
        return view
    }()
    
    let background2: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        return view
    }()
    
    let background3: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        view.layer.cornerRadius = 60
        return view
    }()
    
    //MARK:- TextField Setup
    
    func setupTextFields() {
        view.addSubview(cardView.view)
        cardView.view.backgroundColor = .clear
        cardView.view.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 100, paddingRight: 0, width: 0, height: 0)
        cardView.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(textBackgroundView)
        textBackgroundView.anchor(top: cardView.view.topAnchor, left: cardView.view.leftAnchor, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: screen.width - 80, height: 50)
        
        view.addSubview(emailTextField)
        emailTextField.anchor(top: textBackgroundView.topAnchor, left: textBackgroundView.leftAnchor, bottom: textBackgroundView.bottomAnchor, right: textBackgroundView.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 8, width: 0, height: 0)
        
        view.addSubview(textBackgroundView2)
        textBackgroundView2.anchor(top: nil, left: cardView.view.leftAnchor, bottom: cardView.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 40, paddingBottom: 20, paddingRight: 0, width: screen.width - 80, height: 50)

        view.addSubview(passwordTextField)
        passwordTextField.anchor(top: textBackgroundView2.topAnchor, left: textBackgroundView2.leftAnchor, bottom: textBackgroundView2.bottomAnchor, right: textBackgroundView2.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 8, width: 0, height: 0)
        
        let emailIcon = UIHostingController(rootView: TextIcon(named: "envelope.fill"))
        view.addSubview(emailIcon.view)
        emailIcon.view.backgroundColor = .clear
        emailIcon.view.anchor(top: nil, left: textBackgroundView.leftAnchor, bottom: textBackgroundView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        
        let passwordIcon = UIHostingController(rootView: TextIcon(named: "lock.fill"))
        view.addSubview(passwordIcon.view)
        passwordIcon.view.backgroundColor = .clear
        passwordIcon.view.anchor(top: nil, left: textBackgroundView2.leftAnchor, bottom: textBackgroundView2.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: cardView.view.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter email"
        textField.backgroundColor = .white
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
        return textField
    }()
    
    let textBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemGray3.cgColor
        return view
    }()
    
    let textBackgroundView2: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemGray3.cgColor
        return view
    }()
    
    let cardView = UIHostingController(rootView: CardView())
    
    //MARK:- Login & Create Account
    
    func setupLoginButton() {
        view.addSubview(loginButtonView.view)
        loginButtonView.view.backgroundColor = .clear
        loginButtonView.view.anchor(top: cardView.view.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        loginButtonView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(loginButton)
        loginButton.anchor(top: loginButtonView.view.topAnchor, left: loginButtonView.view.leftAnchor, bottom: loginButtonView.view.bottomAnchor, right: loginButtonView.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleLogin() {


        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if(email.isEmpty || password.isEmpty) {
            presentAlert(message: "Fill Empty Form")
            return
        }
        
        let loadingVC = LoadingViewController()
        loadingVC.modalPresentationStyle = .overFullScreen
        loadingVC.modalTransitionStyle = .crossDissolve
        self.present(loadingVC, animated: true)
        
        Auth.auth().signIn(withEmail: email, password: password) { (_, err) in

            
            if let err = err {
                loadingVC.dismiss(animated: true, completion: {
                    print("error signing in", err)
                    self.presentAlert(message: err.localizedDescription)
                    self.passwordTextField.text = ""
                })
                return
            }
            
            loadingVC.dismiss(animated: true) {
                print("success!")
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.messagesViewController?.observeUserMessages()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func buttonDisabled() -> Bool {
        let emailCount = emailTextField.text?.count ?? 0
        let passwordCount = passwordTextField.text?.count ?? 0
        
        if(emailCount < 6 && passwordCount < 6) {
            return true
        } else {
            return false
        }
    }
    
    @objc func handleCreateAccount() {
        let signInVC = SignUpViewController()
        signInVC.delegate = self
        let navController = UINavigationController(rootViewController: signInVC)
        present(navController, animated: true)
    }
    
    let signUpButton: UIButton = {
        let firstAttributes = [NSAttributedString.Key.foregroundColor : UIColor.systemGray]
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        
        let firstString = NSMutableAttributedString(string: "Don't Have An Account? ", attributes: firstAttributes)
        let secondString = NSAttributedString(string: "Sign Up", attributes: attributes)
        firstString.append(secondString)
        
        let button = UIButton(type: .system)
        let buttonTitle = firstString
        
        button.setAttributedTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(handleCreateAccount), for: .touchUpInside)
        return button
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
}

    //MARK:- SwiftUI View Helpers

struct CardView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .frame(width: screen.width - 40, height: screen.width / 1.5, alignment: .center)
            .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
            .shadow(color: Color.black.opacity(0.2), radius: 22, x: 0, y: 22)
    }
}

struct TextIcon: View {
    @State var named: String
    
    var body: some View {
        Circle()
            .frame(width: 40, height: 40)
            .foregroundColor(Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)))
            .overlay(
                Image(systemName: named)
                    .resizable()
                    .foregroundColor(.white)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            )
            .shadow(color: Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)).opacity(0.6), radius: 22, x: 0, y: 0)
    }
}

struct LogoView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("GoodTalk")
                .font(.system(size: 40, weight: .heavy, design: .default))
                .foregroundColor(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 4, y: 4)
        }
    }
}

struct LoginButton: View {
    
    var body: some View {
        Text("Continue")
            .bold()
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)))
            .clipShape(RoundedRectangle(cornerRadius: 44))
            .shadow(color: Color.black.opacity(0.2), radius: 22, x: 0, y: 12)
    }
}
