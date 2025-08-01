//
//  AccountViewController.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 7/18/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit

// Image Credit: https://www.flaticon.com/authors/freepik and
// https://www.flaticon.com/authors/monkik 🙏
class AccountViewController: UIViewController {

    @IBOutlet weak var offersImage: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TealiumHelper.trackScreen(self, name: "account")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupNameTextField.delegate = self
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
    
    @objc func share() {
        TealiumHelper.trackEvent(title: "share", data: [AccountViewController.contentType: "account screen", AccountViewController.shareId: "accqwe123"])
        let vc = UIActivityViewController(activityItems: ["Account"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    @IBAction func showOfferTapped(_ sender: UIButton) {
        TealiumHelper.trackEvent(title: "show_offers", data: [AccountViewController.adType: "popup", AccountViewController.adSize: "default", AccountViewController.adPlacementId: "abc123", AccountViewController.adMediatedName: "moneybags"])
        offersImage.image = UIImage(named: "bank")
        let ac = UIAlertController(title: "Offers", message: "You have a new offer, please shop and get 10% off a vacuum! This will be applied at checkout when you purchase this item.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @IBAction func joinGroupTapped(_ sender: UIButton) {
        guard let name = groupNameTextField.text else { return }
        var message = "You have joined a group."
        if name != "" {
            message += " The name of your new group is: \(name)"
        }
        let ac = UIAlertController(title: "Welcome", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Great!", style: .default) { _ in
            TealiumHelper.trackEvent(title: "join_group", data: [AccountViewController.groupName: name])
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func addRatingTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Select Rating", message: nil, preferredStyle: .actionSheet)
        for rating in 0...3 {
            ac.addAction(UIAlertAction(title: String(rating), style: .default) { _ in
                self.rate(rating)
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func rate(_ rating: Int) {
        TealiumHelper.trackEvent(title: "rate", data: [AccountViewController.rating: rating])
    }
    
    @IBAction func setAppsFlyerHostTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Set AppsFlyer Host", message: "Enter custom host and prefix for AppsFlyer tracking", preferredStyle: .alert)
        
        ac.addTextField { textField in
            textField.placeholder = "Host (e.g., custom.appsflyer.com)"
            textField.text = "custom.appsflyer.com"
        }
        
        ac.addTextField { textField in
            textField.placeholder = "Host Prefix (e.g., custom-prefix)"
            textField.text = "custom-prefix"
        }
        
        ac.addAction(UIAlertAction(title: "Set Host", style: .default) { _ in
            guard let host = ac.textFields?[0].text, !host.isEmpty,
                  let hostPrefix = ac.textFields?[1].text, !hostPrefix.isEmpty else {
                return
            }
            
            TealiumHelper.trackEvent(title: "set_host", data: [
                AccountViewController.host: host,
                AccountViewController.hostPrefix: hostPrefix
            ])
            
            let successAlert = UIAlertController(title: "Success", message: "AppsFlyer host set to: \(host) with prefix: \(hostPrefix)", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func trackingToggleTapped(_ sender: UISwitch) {
        let isTrackingDisabled = !sender.isOn
        
        TealiumHelper.trackEvent(title: "disable_tracking", data: [
            AccountViewController.stopTracking: isTrackingDisabled
        ])
        
        let message = isTrackingDisabled ? "AppsFlyer tracking has been disabled (privacy mode)" : "AppsFlyer tracking has been enabled"
        let ac = UIAlertController(title: "Tracking Status", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}

extension AccountViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        groupNameTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension AccountViewController {
    static let contentType = "content_type"
    static let shareId = "share_id"
    static let adType = "ad_type"
    static let adPlacementId = "ad_placement_id"
    static let adSize = "ad_size"
    static let adMediatedName = "ad_mediated_name"
    static let groupName = "group_name"
    static let rating = "rating"
    static let host = "host"
    static let hostPrefix = "host_prefix"
    static let stopTracking = "stop_tracking"
}
