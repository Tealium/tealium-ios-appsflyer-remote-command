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

    // MARK: - New AppsFlyer Ad Revenue Features
    @IBAction func logRewardedAdRevenue(_ sender: UIButton) {
        let adRevenue = Double.random(in: 0.01...0.50)
        
        let data: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "Unity Ads",
            "mediation_network": "ironsource",
            "revenue": adRevenue,
            "af_currency": "USD",
            "additional_parameters": [
                "ad_type": "rewarded_video",
                "placement": "level_complete",
                "ad_unit": "main_rewarded",
                "level": levelLabel.text ?? "1"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "log_rewarded_ad_revenue", data: data)
        showAlert(message: "Rewarded ad revenue logged: $\(String(format: "%.2f", adRevenue))")
    }
    
    @IBAction func logInterstitialAdRevenue(_ sender: UIButton) {
        let adRevenue = Double.random(in: 0.005...0.20)
        
        let data: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "AdMob",
            "mediation_network": "googleadmob",
            "revenue": adRevenue,
            "af_currency": "USD",
            "additional_parameters": [
                "ad_type": "interstitial",
                "placement": "between_levels",
                "ad_unit": "main_interstitial"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "log_interstitial_ad_revenue", data: data)
        showAlert(message: "Interstitial ad revenue logged: $\(String(format: "%.2f", adRevenue))")
    }
    
    @IBAction func logBannerAdRevenue(_ sender: UIButton) {
        let adRevenue = Double.random(in: 0.001...0.05)
        
        let data: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "Facebook",
            "mediation_network": "applovinmax",
            "revenue": adRevenue,
            "af_currency": "USD",
            "additional_parameters": [
                "ad_type": "banner",
                "placement": "main_screen",
                "ad_unit": "main_banner",
                "ad_size": "320x50"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "log_banner_ad_revenue", data: data)
        showAlert(message: "Banner ad revenue logged: $\(String(format: "%.3f", adRevenue))")
    }
    
    // MARK: - Advanced Gaming Features
    @IBAction func validateInAppPurchase(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "validateandlogpurchase",
            "purchase_type": "one_time_purchase",
            "product_id": "remove_ads",
            "price": "2.99",
            "currency": "USD",
            "purchase_token": "gaming_iap_token_\(Int.random(in: 1000...9999))",
            "additional_parameters": [
                "category": "monetization",
                "player_level": levelLabel.text ?? "1"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "validate_gaming_purchase", data: data)
        showAlert(message: "In-app purchase validated: Remove Ads $2.99")
    }
    
    @IBAction func trackGameSession(_ sender: UIButton) {
        let sessionData: [String: Any] = [
            "session_length": Int.random(in: 60...1800), // 1-30 minutes
            "levels_completed": Int.random(in: 1...5),
            "score_achieved": Int.random(in: 1000...50000),
            "coins_earned": Int.random(in: 10...500),
            "ads_watched": Int.random(in: 0...3)
        ]
        
        let data: [String: Any] = [
            "command_name": "setadditionaldata",
            "additional_data": sessionData
        ]
        
        TealiumHelper.trackEvent(title: "track_game_session", data: data)
        showAlert(message: "Game session data tracked")
    }
    
    // MARK: - Helper Method
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Gaming", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
