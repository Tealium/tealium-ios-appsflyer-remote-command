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
    
    @IBAction func setConsentDataTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Set Consent Data", message: "Configure GDPR consent settings", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "EU User - Full Consent", style: .default) { _ in
            TealiumHelper.trackEvent(title: "set_consent", data: [
                AccountViewController.isUserSubjectToGDPR: true,
                AccountViewController.hasConsentForDataUsage: true,
                AccountViewController.hasConsentForAdsPersonalization: true,
                AccountViewController.hasConsentForAdStorage: true
            ])
            self.showConsentResult("Full consent granted for EU user")
        })
        
        ac.addAction(UIAlertAction(title: "EU User - Limited Consent", style: .default) { _ in
            TealiumHelper.trackEvent(title: "set_consent", data: [
                AccountViewController.isUserSubjectToGDPR: true,
                AccountViewController.hasConsentForDataUsage: true,
                AccountViewController.hasConsentForAdsPersonalization: false,
                AccountViewController.hasConsentForAdStorage: false
            ])
            self.showConsentResult("Limited consent for EU user (no ads personalization)")
        })
        
        ac.addAction(UIAlertAction(title: "Non-EU User", style: .default) { _ in
            TealiumHelper.trackEvent(title: "set_consent", data: [
                AccountViewController.isUserSubjectToGDPR: false,
                AccountViewController.hasConsentForDataUsage: true,
                AccountViewController.hasConsentForAdsPersonalization: true,
                AccountViewController.hasConsentForAdStorage: true
            ])
            self.showConsentResult("Non-EU user - full tracking enabled")
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func logAdRevenueTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Log Ad Revenue", message: "Test ad revenue tracking with different networks", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Google AdMob - $0.05", style: .default) { _ in
            TealiumHelper.trackEvent(title: "ad_revenue", data: [
                AccountViewController.monetizationNetwork: "AdMob",
                AccountViewController.mediationNetwork: "googleadmob",
                AccountViewController.adRevenueCurrency: "USD",
                AccountViewController.adRevenueAmount: 0.05,
                AccountViewController.adRevenueAdUnitId: "ca-app-pub-123456789/1234567890",
                AccountViewController.adRevenueAdFormat: "banner",
                AccountViewController.adRevenuePlacement: "main_screen"
            ])
            self.showAdRevenueResult("AdMob banner ad revenue: $0.05")
        })
        
        ac.addAction(UIAlertAction(title: "IronSource - $0.12", style: .default) { _ in
            TealiumHelper.trackEvent(title: "ad_revenue", data: [
                AccountViewController.monetizationNetwork: "IronSource",
                AccountViewController.mediationNetwork: "ironsource",
                AccountViewController.adRevenueCurrency: "USD",
                AccountViewController.adRevenueAmount: 0.12,
                AccountViewController.adRevenueInstanceId: "DefaultInterstitial",
                AccountViewController.adRevenueAdFormat: "interstitial",
                AccountViewController.adRevenueCountry: "US"
            ])
            self.showAdRevenueResult("IronSource interstitial ad revenue: $0.12")
        })
        
        ac.addAction(UIAlertAction(title: "Unity - $0.08", style: .default) { _ in
            TealiumHelper.trackEvent(title: "ad_revenue", data: [
                AccountViewController.monetizationNetwork: "Unity",
                AccountViewController.mediationNetwork: "unity",
                AccountViewController.adRevenueCurrency: "USD",
                AccountViewController.adRevenueAmount: 0.08,
                AccountViewController.adRevenuePlacementId: "rewardedVideo",
                AccountViewController.adRevenueAdFormat: "rewarded",
                AccountViewController.adRevenueCompletion: true
            ])
            self.showAdRevenueResult("Unity rewarded video ad revenue: $0.08")
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func setPartnerDataTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Set Partner Data", message: "Send custom data to AppsFlyer partners", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Analytics Partner", style: .default) { _ in
            TealiumHelper.trackEvent(title: "set_partner_data", data: [
                AccountViewController.partnerId: "analytics_partner_int",
                AccountViewController.partnerPuid: "user_12345",
                AccountViewController.partnerUserSegment: "premium",
                AccountViewController.partnerLtv: 150.75,
                AccountViewController.partnerEngagementScore: 8.5
            ])
            self.showPartnerDataResult("Analytics partner data sent")
        })
        
        ac.addAction(UIAlertAction(title: "Marketing Partner", style: .default) { _ in
            TealiumHelper.trackEvent(title: "set_partner_data", data: [
                AccountViewController.partnerId: "marketing_partner_int",
                AccountViewController.partnerPuid: "marketing_user_67890",
                AccountViewController.partnerUserSegment: "high_value",
                AccountViewController.partnerLtv: 299.99
            ])
            self.showPartnerDataResult("Marketing partner data sent")
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func setSharingFilterTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Set Sharing Filter", message: "Control which partners receive data", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Block Facebook & Google", style: .default) { _ in
            TealiumHelper.trackEvent(title: "set_sharing_filter", data: [
                AccountViewController.sharingFilter: ["facebook_int", "googleads_int"]
            ])
            self.showSharingFilterResult("Blocked data sharing with Facebook and Google")
        })
        
        ac.addAction(UIAlertAction(title: "Block All Partners", style: .default) { _ in
            TealiumHelper.trackEvent(title: "set_sharing_filter", data: [
                AccountViewController.sharingFilter: ["all"]
            ])
            self.showSharingFilterResult("Blocked data sharing with all partners")
        })
        
        ac.addAction(UIAlertAction(title: "Reset Filter (Allow All)", style: .default) { _ in
            TealiumHelper.trackEvent(title: "set_sharing_filter", data: [:])
            self.showSharingFilterResult("Reset sharing filter - all partners allowed")
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // Helper methods for showing results
    private func showConsentResult(_ message: String) {
        let ac = UIAlertController(title: "Consent Updated", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    private func showAdRevenueResult(_ message: String) {
        let ac = UIAlertController(title: "Ad Revenue Logged", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    private func showPartnerDataResult(_ message: String) {
        let ac = UIAlertController(title: "Partner Data Sent", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    private func showSharingFilterResult(_ message: String) {
        let ac = UIAlertController(title: "Sharing Filter Updated", message: message, preferredStyle: .alert)
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
    
    // New function parameters
    static let isUserSubjectToGDPR = "is_user_subject_to_gdpr"
    static let hasConsentForDataUsage = "has_consent_for_data_usage"
    static let hasConsentForAdsPersonalization = "has_consent_for_ads_personalization"
    static let hasConsentForAdStorage = "has_consent_for_ad_storage"
    
    static let monetizationNetwork = "monetization_network"
    static let mediationNetwork = "mediation_network"
    static let adRevenueCurrency = "ad_revenue_currency"
    static let adRevenueAmount = "ad_revenue_amount"
    static let adRevenueAdUnitId = "ad_revenue_ad_unit_id"
    static let adRevenueAdFormat = "ad_revenue_ad_format"
    static let adRevenuePlacement = "ad_revenue_placement"
    static let adRevenueInstanceId = "ad_revenue_instance_id"
    static let adRevenueCountry = "ad_revenue_country"
    static let adRevenuePlacementId = "ad_revenue_placement_id"
    static let adRevenueCompletion = "ad_revenue_completion"
    static let partnerId = "partner_id"
    static let partnerPuid = "partner_puid"
    static let partnerUserSegment = "partner_user_segment"
    static let partnerLtv = "partner_ltv"
    static let partnerEngagementScore = "partner_engagement_score"
    
    static let sharingFilter = "sharing_filter"
}
