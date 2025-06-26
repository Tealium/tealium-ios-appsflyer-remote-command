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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TealiumHelper.trackScreen(self, name: "account")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func addPushDeepLinkPath(_ sender: UIButton) {
        let data: [String: Any] = [
            "push_notification_deep_link_path": ["offers", "profile", "rewards"]
        ]
        
        TealiumHelper.trackEvent(title: "add_push_notification_deep_link_path", data: data)
        showAlert(title: "Deep Link Path", message: "Push notification deep link paths added")
    }

    
}

extension AccountViewController {
    static let contentType = "content_type"
    static let shareId = "share_id" 
    static let adType = "ad_type"
    static let adNetworkName = "ad_network_name"
    static let adPlacementId = "ad_placement_id"
    static let adSize = "ad_size"
    static let adMediatedName = "ad_mediated_name"
    static let groupName = "group_name"
    static let rating = "rating"
}
