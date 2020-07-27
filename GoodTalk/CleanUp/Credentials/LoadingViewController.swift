//
//  LoadingViewController.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 7/25/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI

class LoadingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        view.addSubview(blurView)
        blurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        showLoadingView()
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 30
        return view
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

struct LoadingRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<LoadingRepresentable>) -> UIViewController {
        let viewController = LoadingViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<LoadingRepresentable>) {
    }
    
    typealias UIViewControllerType = UIViewController
}

struct LoadingViewController_Previews: PreviewProvider {
    static var previews: some View {
        LoadingRepresentable()
    }
}
