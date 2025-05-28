//
//  AdvancedFeaturesViewController.swift
//  TealiumAppsFlyerExample
//
//  Created by AI Assistant
//  Copyright © 2024 Tealium. All rights reserved.
//

import UIKit

class AdvancedFeaturesViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var customerIdTextField: UITextField!
    @IBOutlet weak var sessionTimeTextField: UITextField!
    @IBOutlet weak var consentSwitch: UISwitch!
    @IBOutlet weak var adTrackingSwitch: UISwitch!
    @IBOutlet weak var networkDataSwitch: UISwitch!
    @IBOutlet weak var appsetIdSwitch: UISwitch!
    @IBOutlet weak var debugSwitch: UISwitch!
    @IBOutlet weak var waitForUserIdSwitch: UISwitch!
    @IBOutlet weak var isUpdateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        TealiumHelper.trackScreen(self, name: "Advanced Features")
    }
    
    private func setupUI() {
        title = "Advanced Features"
        view.backgroundColor = .systemBackground
        
        // Set default values
        sessionTimeTextField.text = "30"
        phoneTextField.placeholder = "+1234567890"
        customerIdTextField.placeholder = "user123"
        
        // Switch default states
        consentSwitch.isOn = true
        adTrackingSwitch.isOn = false
        networkDataSwitch.isOn = false
        appsetIdSwitch.isOn = true
        debugSwitch.isOn = true
        waitForUserIdSwitch.isOn = false
        isUpdateSwitch.isOn = false
    }
    
    // MARK: - Phone Number
    @IBAction func setPhoneNumber(_ sender: UIButton) {
        guard let phoneNumber = phoneTextField.text, !phoneNumber.isEmpty else {
            showAlert(message: "Please enter a phone number")
            return
        }
        
        let data: [String: Any] = [
            "command_name": "setphonenumber",
            "phone_number": phoneNumber
        ]
        
        TealiumHelper.trackEvent(title: "set_phone_number", data: data)
        showAlert(message: "Phone number set: \(phoneNumber)")
    }
    
    // MARK: - Customer ID & Session
    @IBAction func setCustomerIdAndLogSession(_ sender: UIButton) {
        guard let customerId = customerIdTextField.text, !customerId.isEmpty else {
            showAlert(message: "Please enter a customer ID")
            return
        }
        
        let data: [String: Any] = [
            "command_name": "setcustomeridandlogsession",
            "af_customer_user_id": customerId
        ]
        
        TealiumHelper.trackEvent(title: "set_customer_id_session", data: data)
        showAlert(message: "Customer ID set and session logged: \(customerId)")
    }
    
    // MARK: - Session Management
    @IBAction func logSession(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "logsession"
        ]
        
        TealiumHelper.trackEvent(title: "log_session", data: data)
        showAlert(message: "Session logged manually")
    }
    
    @IBAction func setMinTimeBetweenSessions(_ sender: UIButton) {
        guard let timeText = sessionTimeTextField.text,
              let timeSeconds = Int(timeText) else {
            showAlert(message: "Please enter valid number of seconds")
            return
        }
        
        let data: [String: Any] = [
            "command_name": "setmintimebetweensessions",
            "min_time_between_sessions": timeSeconds
        ]
        
        TealiumHelper.trackEvent(title: "set_session_time", data: data)
        showAlert(message: "Min time between sessions set to \(timeSeconds) seconds")
    }
    
    // MARK: - Privacy & Consent
    @IBAction func setDMAConsent(_ sender: UIButton) {
        let consentValue = consentSwitch.isOn
        
        let data: [String: Any] = [
            "command_name": "setdmaconsent",
            "gdpr_applies": true,
            "consent_for_data_usage": consentValue,
            "consent_for_ads_personalization": consentValue,
            "consent_for_ad_storage": consentValue
        ]
        
        TealiumHelper.trackEvent(title: "set_dma_consent", data: data)
        showAlert(message: "DMA Consent set to: \(consentValue ? "Granted" : "Denied")")
    }
    
    @IBAction func anonymizeUser(_ sender: UIButton) {
        let anonymize = true // Always anonymize when button pressed
        
        let data: [String: Any] = [
            "command_name": "anonymizeuser",
            "anonymize_user": anonymize
        ]
        
        TealiumHelper.trackEvent(title: "anonymize_user", data: data)
        showAlert(message: "User anonymized")
    }
    
    // MARK: - Tracking Controls
    @IBAction func toggleAdTracking(_ sender: UISwitch) {
        let disable = sender.isOn
        
        let data: [String: Any] = [
            "command_name": "setdisableadvertisingidentifiers",
            "disable_advertising_identifiers": disable
        ]
        
        TealiumHelper.trackEvent(title: "toggle_ad_tracking", data: data)
    }
    
    @IBAction func toggleNetworkData(_ sender: UISwitch) {
        let disable = sender.isOn
        
        let data: [String: Any] = [
            "command_name": "setdisablenetworkdata",
            "disable_network_data": disable
        ]
        
        TealiumHelper.trackEvent(title: "toggle_network_data", data: data)
    }
    
    @IBAction func toggleAppsetId(_ sender: UISwitch) {
        let enable = sender.isOn
        
        let data: [String: Any] = [
            "command_name": "enableappsetid",
            "enable_appset_id": enable
        ]
        
        TealiumHelper.trackEvent(title: "toggle_appset_id", data: data)
    }
    
    @IBAction func toggleWaitForUserId(_ sender: UISwitch) {
        let wait = sender.isOn
        
        let data: [String: Any] = [
            "command_name": "waitforcustomeruserid",
            "wait_for_customer_user_id": wait
        ]
        
        TealiumHelper.trackEvent(title: "toggle_wait_user_id", data: data)
    }
    
    @IBAction func toggleIsUpdate(_ sender: UISwitch) {
        let isUpdate = sender.isOn
        
        let data: [String: Any] = [
            "command_name": "setisupdate",
            "is_update": isUpdate
        ]
        
        TealiumHelper.trackEvent(title: "toggle_is_update", data: data)
    }
    
    // MARK: - Advanced Features
    @IBAction func logAdRevenue(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "Unity Ads",
            "mediation_network": "ironsource",
            "revenue": 0.25,
            "af_currency": "USD",
            "additional_parameters": [
                "placement": "rewarded_video",
                "ad_unit": "main_menu"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "log_ad_revenue", data: data)
        showAlert(message: "Ad revenue logged: $0.25 USD")
    }
    
    @IBAction func validatePurchase(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "validateandlogpurchase",
            "purchase_type": "subscription",
            "product_id": "premium_monthly",
            "price": "9.99",
            "currency": "USD",
            "purchase_token": "sample_receipt_token_123",
            "additional_parameters": [
                "subscription_period": "monthly",
                "trial_period": "7_days"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "validate_purchase", data: data)
        showAlert(message: "Purchase validated: Premium Monthly $9.99")
    }
    
    @IBAction func enableTCFDataCollection(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "enabletcfdatacollection",
            "enable_tcf_data_collection": true
        ]
        
        TealiumHelper.trackEvent(title: "enable_tcf", data: data)
        showAlert(message: "TCF Data Collection enabled")
    }
    
    @IBAction func setOutOfStore(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "setoutofstore",
            "out_of_store_source": "amazon_appstore"
        ]
        
        TealiumHelper.trackEvent(title: "set_out_of_store", data: data)
        showAlert(message: "Out of store source set: Amazon Appstore")
    }
    
    @IBAction func setSharingFilter(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "setsharingfilterforpartners",
            "sharing_filter_partners": ["facebook_int", "googleadwords_int", "snapchat_int"]
        ]
        
        TealiumHelper.trackEvent(title: "set_sharing_filter", data: data)
        showAlert(message: "Sharing filter set for selected partners")
    }
    
    @IBAction func setAdditionalData(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "setadditionaldata",
            "additional_data": [
                "custom_attribute_1": "value1",
                "custom_attribute_2": "value2",
                "user_segment": "premium",
                "experiment_group": "A"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "set_additional_data", data: data)
        showAlert(message: "Additional data set with custom attributes")
    }
    
    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "AppsFlyer", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 