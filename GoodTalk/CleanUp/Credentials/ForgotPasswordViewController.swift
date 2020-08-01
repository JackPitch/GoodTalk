//
//  ForgotPasswordViewController.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 7/28/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

protocol ForgotPasswordDelegate: class {
    func didResetPassword()
}

class ForgotPasswordViewController: UIViewController {
    
    let background = UIHostingController(rootView: ResetBackground())
    let resetButtonLabel = UIHostingController(rootView: EmailResetButton())
    let textField = UIHostingController(rootView: EmailResetField())
    let logo = UIHostingController(rootView: ResetLockLogo())
    let exitButtonLabel = UIHostingController(rootView: ExitResetButton())
    
    var delegate: ForgotPasswordDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupResetEmailButton()
        setupTextField()
        setupExitButton()
        setupLoadingCard()
        setupErrorLabel()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleDismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func setupErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.alpha = 0
        errorLabel.anchor(top: nil, left: nil, bottom: logo.view.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 0, width: screen.width - 80, height: 0)
        errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setupLoadingCard() {
        view.addSubview(activityIndicator)
        activityIndicator.alpha = 0
        activityIndicator.anchor(top: logo.view.topAnchor, left: nil, bottom: logo.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setupResetEmailButton() {
        view.addSubview(resetButtonLabel.view)
        resetButtonLabel.view.backgroundColor = .clear
        resetButtonLabel.view.anchor(top: nil, left: nil, bottom: background.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        resetButtonLabel.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(resetButton)
        resetButton.anchor(top: resetButtonLabel.view.topAnchor, left: resetButtonLabel.view.leftAnchor, bottom: resetButtonLabel.view.bottomAnchor, right: resetButtonLabel.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupTextField() {
        view.addSubview(textField.view)
        textField.view.backgroundColor = .clear
        textField.view.anchor(top: nil, left: nil, bottom: resetButtonLabel.view.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 0)
        textField.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(emailTextField)
        emailTextField.anchor(top: textField.view.topAnchor, left: textField.view.leftAnchor, bottom: textField.view.bottomAnchor, right: textField.view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: screen.width - 70, height: 0)
        
        view.addSubview(logo.view)
        logo.view.backgroundColor = .clear
        logo.view.anchor(top: nil, left: nil, bottom: textField.view.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        logo.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(lockImageView)
        lockImageView.anchor(top: logo.view.topAnchor, left: logo.view.leftAnchor, bottom: logo.view.bottomAnchor, right: logo.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupBackground() {
        let blurEffet = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffet)
        
        view.addSubview(blurView)
        blurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(background.view)
        background.view.backgroundColor = .clear
        background.view.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 100, paddingRight: 0, width: 0, height: 0)
        background.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupExitButton() {
        view.addSubview(exitButtonLabel.view)
        exitButtonLabel.view.backgroundColor = .clear
        exitButtonLabel.view.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        view.addSubview(exitButton)
        exitButton.anchor(top: exitButtonLabel.view.topAnchor, left: exitButtonLabel.view.leftAnchor, bottom: exitButtonLabel.view.bottomAnchor, right: exitButtonLabel.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func showLoading() {
        lockImageView.alpha = 0
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
    }
    
    func dismissLoading() {
        lockImageView.alpha = 1
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let lockImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock.rotation")
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Email"
        return tf
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Please Enter Email"
        label.textColor = UIColor.systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleReset() {
        guard let email = emailTextField.text else { return }
        
        if(email.isEmpty) {
            errorLabel.text = "Please Enter Email"
            errorLabel.alpha = 1
            return
        }
        
        showLoading()

        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if let err = err {
                self.errorLabel.alpha = 1
                self.errorLabel.text = err.localizedDescription
                print("error sending password reset", err)
                self.dismissLoading()
                return
            }
            self.errorLabel.alpha = 0
            self.dismissLoading()
            self.dismiss(animated: true) {
                self.delegate.didResetPassword()
            }
        }
    }
}

struct ExitResetButton: View {
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
    }
}

struct ForgotView: View {
    @State var email: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ResetBackground()
                Spacer()
                Spacer()
            }
            
            VStack {
                Spacer()
                VStack {
                    VStack(spacing: 22) {
                        ResetLockLogo()
                        EmailResetField()
                        EmailResetButton()
                    }
                }
                Spacer()
                Spacer()
            }
        }
    }
}

struct ForgotPasswordViewController_Previews: PreviewProvider {
    static var previews: some View {
        ForgotView()
    }
}

struct EmailResetField: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .frame(width: screen.width - 90, height: 50)
            .padding(.horizontal, 10)
            .foregroundColor(.clear)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .foregroundColor(Color(UIColor.systemGray3))
        )
    }
}

struct EmailResetButton: View {
    var body: some View {
        Button(action: {
            print("reset password")
        }) {
            Text("Reset Password")
                .bold()
                .foregroundColor(.white)
                .frame(width: screen.width - 60, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .foregroundColor(Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)))
                        .shadow(color: Color(#colorLiteral(red: 0.708395762, green: 0.8466395548, blue: 0.9638805651, alpha: 1)).opacity(0.8), radius: 12, x: 0, y: 12)
            )
        }
    }
}

struct ResetLockLogo: View {
    var body: some View {
//        Image(systemName: "lock.rotation")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .foregroundColor(Color(UIColor.systemGray3))
            .frame(width: 70, height: 70)
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 0)
            .padding(.bottom)
    }
}

struct ResetBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .foregroundColor(Color(UIColor.systemGray6))
            .frame(width: screen.width - 20, height: 200)
            .padding(.top, 40)
    }
}

class SuccessResetViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlurView()
        setupBackground()
        setupButton()
        setupMessageLabel()
    }
    
    func setupBackground() {
        view.addSubview(backgroundView)
        backgroundView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: screen.width / 1.5, height: screen.width / 2)
        backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupButton() {
        view.addSubview(doneButton)
        doneButton.anchor(top: nil, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 50)
    }
    
    func setupMessageLabel() {
        view.addSubview(messageLabel)
        messageLabel.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: doneButton.topAnchor, right: backgroundView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
    }
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 22
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Successfully reset password! Instructions have been sent to your email! ✅"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ok", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupBlurView() {
        let blurEffet = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffet)
        
        view.addSubview(blurView)
        blurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
