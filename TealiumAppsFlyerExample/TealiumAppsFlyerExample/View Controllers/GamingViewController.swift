//
//  GamingViewController.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 7/19/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit

class GamingViewController: UIViewController {

    @IBOutlet weak var startTutorialButton: UIButton!
    @IBOutlet weak var stopTutorialButton: UIButton!
    @IBOutlet weak var achievementLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var customEventButton: UIButton!

    var data = [String: Any]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TealiumHelper.trackScreen(self, name: "gaming")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
    

    @objc func share() {
        TealiumHelper.trackEvent(title: "share", data: [GamingViewController.contentType: "gaming screen", GamingViewController.shareId: "gamqwe123"])
        let vc = UIActivityViewController(activityItems: ["Gaming"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    @IBAction func spendCurrency(_ sender: UIButton) {
        TealiumHelper.trackEvent(title: "spend_currency", data: [GamingViewController.productName: ["jewels"], "currency_type": GamingViewController.tokens, GamingViewController.creditPrice: [50.00]])
    }
    
    @IBAction func achievementSwitch(_ sender: UISwitch) {
        if sender.isOn {
            TealiumHelper.trackEvent(title: "unlock_achievement", data: [GamingViewController.achievementId: "\(Int.random(in: 1...1000))"])
            achievementLabel.text = "Lock Achievement"
        } else {
            achievementLabel.text = "Unlock Achievement"
        }
        
    }
    
    @IBAction func levelStepper(_ sender: UIStepper) {
        levelLabel.text = String(Int(sender.value))
        data[GamingViewController.level] = Int(sender.value)
        data[GamingViewController.charachter] = "mario"
        TealiumHelper.trackEvent(title: "level_up", data: data)
    }
    
    
    @IBAction func startTrial(_ sender: UIButton) {
        TealiumHelper.trackEvent(title: "start_trial", data: [GamingViewController.trialPrice: [0.00]])
    }
    
    @IBAction func stopTutorial(_ sender: UIButton) {
        TealiumHelper.trackEvent(title: "stop_tutorial", data: ["tutorial_id": "123asdf"])
    }
    
    @IBAction func reEngage(_ sender: Any) {
        data[GamingViewController.score] = Int.random(in: 1...1000) * 1000
        TealiumHelper.trackEvent(title: "reengage", data: data)
    }
    
    @IBAction func customEvent(_ sender: Any) {
        TealiumHelper.trackEvent(title: "custom_event", data: [:])
    }

}

extension GamingViewController {
    static let contentType = "content_type"
    static let shareId = "share_id"
    static let productName = "product_name"
    static let currencyType = "currency_type"
    static let tokens = "tokens"
    static let achievementId = "achievement_id"
    static let level = "level"
    static let charachter = "character"
    static let score = "score"
    static let creditPrice = "price"
    static let trialPrice = "price"
}
