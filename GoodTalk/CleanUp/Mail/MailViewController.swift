//
//  RequestsViewController.swift
//  GoodTalk
//
//  Created by Jackson Pitcher on 9/18/20.
//  Copyright © 2020 Jackson Pitcher. All rights reserved.
//

import SwiftUI
import Firebase

class MailViewController: UIViewController {
        
    let requestsTableVC = RequestsTableVC()
    let sentRequestsTableVC = SentRequestsTableVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Mail"
        setupSegmentedControl()
        setupRequestsTableView()
        setupSentRequestsTableView()
    }
    
    func setupSegmentedControl() {
        view.addSubview(segmentControl)
        segmentControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentControl.selectedSegmentIndex = 0
    }
    
    func setupRequestsTableView() {
        view.addSubview(requestsTableVC.view)
        requestsTableVC.view.anchor(top: segmentControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupSentRequestsTableView() {
        view.addSubview(sentRequestsTableVC.view)
        sentRequestsTableVC.view.anchor(top: segmentControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.bringSubviewToFront(requestsTableVC.view)
    }
    
    let segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "Requests", at: 0, animated: true)
        segment.insertSegment(withTitle: "Sent Requests", at: 1, animated: true)
        segment.addTarget(self, action: #selector(handleToggle), for: .valueChanged)
        return segment
    }()
    
    @objc func handleToggle() {
        let index = segmentControl.selectedSegmentIndex
        switch index {
        case 0:
            view.bringSubviewToFront(requestsTableVC.view)
            break
        case 1:
            view.bringSubviewToFront(sentRequestsTableVC.view)
            break
        default:
            break
        }
    }
    
    let noRequestsView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope.open"))
        iv.tintColor = .systemGray4
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let noRequestsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Requests"
        label.textColor = .systemGray4
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        return label
    }()
}

struct NoMailView: View {
    var message = "No Requests"
    
    init(message: String) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.white)
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                Image(systemName: "envelope.open")
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                    .foregroundColor(Color(UIColor.systemGray4))
                    .aspectRatio(contentMode: .fit)
                Text(message)
                    .font(.system(size: 32, weight: .semibold, design: .default))
                    .foregroundColor(Color(UIColor.systemGray4))
                Spacer()
                Spacer()
            }
        }
    }
}
