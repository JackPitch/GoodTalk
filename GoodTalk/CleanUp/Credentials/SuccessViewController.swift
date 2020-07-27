//
//  SuccessViewController.swift
//  Good-Talk
//
//  Created by Jackson Pitcher on 7/19/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

class SuccessViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        view.addSubview(blurView)
        blurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 280, height: 280)
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(iconView)
        iconView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(messageLabel)
        messageLabel.anchor(top: iconView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        
        view.addSubview(activityIndicator)
        activityIndicator.anchor(top: messageLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        activityIndicator.startAnimating()
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        view.layer.cornerRadius = 60
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Created User! ..."
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    let iconView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(systemName: "hand.thumbsup.fill")
        icon.clipsToBounds = true
        icon.contentMode = .scaleAspectFill
        icon.tintColor = .white
        return icon
    }()
    
    func showLoadingView() {
        let loadingView = UIView()
        view.addSubview(loadingView)
        
        loadingView.backgroundColor = .systemBackground
        loadingView.alpha = 0
        
        UIView.animate(withDuration: 0.25) { loadingView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
}

struct SuccessViewController_Previews: PreviewProvider {
    static var previews: some View {
        SuccessRepresentable()
    }
}

struct SuccessRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<SuccessRepresentable>) -> UIViewController {
        let viewController = SuccessViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<SuccessRepresentable>) {
    }
    
    typealias UIViewControllerType = UIViewController
    
}
