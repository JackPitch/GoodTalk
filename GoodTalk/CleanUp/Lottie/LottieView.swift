//
//  LottieView.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 10/5/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Lottie

class LottieVC: UIViewController {
    let lottieView = AnimationView()
    
    let animation = Animation.named("addedContact")
    
    var animationMessage: String? {
        didSet {
            label.text = animationMessage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lottieView.animation = animation
        lottieView.contentMode = .scaleAspectFit
        lottieView.animationSpeed = 1.6
        lottieView.play()
        view.addSubview(lottieView)
        lottieView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        lottieView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.addSubview(label)
        label.anchor(top: view.centerYAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Sent Request!"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.9607843137, green: 0.7098039216, blue: 0.2, alpha: 1)
        return label
    }()
}

struct LottieVCRepresentable: UIViewControllerRepresentable {
    
    let lottieVC = LottieVC()
    
    init(animationMessage: String) {
        lottieVC.animationMessage = animationMessage
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<LottieVCRepresentable>) -> UIViewController {
        return lottieVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<LottieVCRepresentable>) {
    }
    
    typealias UIViewControllerType = UIViewController
}

struct LottieCard: View {
    var boxSize = screen.width / 1.3
    
    var animationMessage: String?
    
    init(animationMessage: String) {
        self.animationMessage = animationMessage
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: boxSize / 5, style: .continuous)
                .frame(width: boxSize, height: boxSize, alignment: .center)
            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
            .padding(.top, 20)
            .shadow(color: Color.black.opacity(0.2), radius: 22, x: 0, y: 0)
            LottieVCRepresentable(animationMessage: animationMessage ?? "Request Sent")
        }
    }
}

struct Lottie_Previews: PreviewProvider {
    static var previews: some View {
        LottieCard(animationMessage: "Hello")
    }
}
