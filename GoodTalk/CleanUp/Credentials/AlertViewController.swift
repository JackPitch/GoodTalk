//
//  AlertViewController.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/18/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

class AlertViewController: UIViewController {
    
    let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 22
        view.backgroundColor = .systemGray6
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Something went wrong"
        label.tintColor = .gray
        label.font = .preferredFont(forTextStyle: .callout)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let warningIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .black
        return iv
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ok", for: .normal)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    init(message: String) {
        super.init(nibName: nil, bundle: nil)
        
        messageLabel.text = message
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 250)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        
        view.addSubview(warningIcon)
        warningIcon.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
        warningIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        view.addSubview(doneButton)
        doneButton.anchor(top: nil, left: nil, bottom: containerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 230, height: 50)
        doneButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        view.addSubview(messageLabel)
        messageLabel.anchor(top: warningIcon.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 210, height: 0)
        messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurView)
        blurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct AlertRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertRepresentable>) -> UIViewController {
        let viewController = AlertViewController(message: "Something went wrong")
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AlertRepresentable>) {
    }
    
    typealias UIViewControllerType = UIViewController
}


struct Extension_Previews: PreviewProvider {
    static var previews: some View {
        AlertRepresentable()
    }
}
