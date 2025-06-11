import UIKit

class AdvancedFeaturesViewController: UIViewController {
    
    // MARK: - Outlets (tylko te które są w storyboard)
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var customerIdTextField: UITextField!
    @IBOutlet weak var consentSwitch: UISwitch!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TealiumHelper.trackScreen(self, name: "advanced_features")
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Advanced Features"
        
        // Set placeholders
        phoneTextField.placeholder = "+1234567890"
        customerIdTextField.placeholder = "user123"
        
        // Default switch state
        consentSwitch.isOn = true
        
        // Setup navigation
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action, 
            target: self, 
            action: #selector(share)
        )
    }
    
    @objc func share() {
        TealiumHelper.trackEvent(title: "share", data: ["content_type": "advanced_features_screen"])
        let vc = UIActivityViewController(activityItems: ["Advanced Features"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    // MARK: - Phone Number Actions
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
    
    // MARK: - Advanced AppsFlyer Features
    @IBAction func logAdRevenue(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "Unity Ads",
            "mediation_network": "ironsource",
            "ad_revenue": 0.25,
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
            "purchase_currency": "USD",
            "transaction_id": "sample_transaction_id_123",
            "additional_parameters": [
                "subscription_period": "monthly",
                "trial_period": "7_days"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "validate_purchase", data: data)
        showAlert(message: "Purchase validated: Premium Monthly $9.99")
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
        let data: [String: Any] = [
            "command_name": "anonymizeuser",
            "anonymize_user": true
        ]
        
        TealiumHelper.trackEvent(title: "anonymize_user", data: data)
        showAlert(message: "User anonymized")
    }
    
    @IBAction func setSharingFilter(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "setsharingfilterforpartners",
            "sharing_filter_partners": ["facebook_int", "googleadwords_int", "snapchat_int"]
        ]
        
        TealiumHelper.trackEvent(title: "set_sharing_filter", data: data)
        showAlert(message: "Sharing filter set for selected partners")
    }
    
    @IBAction func appendCustomData(_ sender: UIButton) {
        let data: [String: Any] = [
            "command_name": "appendcustomdata",
            "custom_data_to_append": [
                "custom_attribute_1": "value1",
                "custom_attribute_2": "value2",
                "user_segment": "premium",
                "experiment_group": "A"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "append_custom_data", data: data)
        showAlert(message: "Additional data set with custom attributes")
    }
    
    // MARK: - New Advanced Features (Previously Missing)
    @IBAction func setDeviceLanguage(_ sender: UIButton) {
        let languages = ["en", "es", "fr", "de", "ja", "zh", "ru"]
        let selectedLanguage = languages.randomElement()!
        
        let data: [String: Any] = [
            "command_name": "setcurrentdevicelanguage",
            "device_language": selectedLanguage
        ]
        
        TealiumHelper.trackEvent(title: "set_device_language", data: data)
        showAlert(message: "Device language set to: \(selectedLanguage)")
    }
    
    @IBAction func setPartnerData(_ sender: UIButton) {
        let partnerInfo: [String: Any] = [
            "campaign_id": "summer_2024",
            "creative_id": "banner_001",
            "placement": "home_screen",
            "user_segment": "premium",
            "partner_user_id": "partner_\(Int.random(in: 1000...9999))"
        ]
        
        let data: [String: Any] = [
            "command_name": "setpartnerdata",
            "partner_id": "facebook_int",
            "partner_info": partnerInfo
        ]
        
        TealiumHelper.trackEvent(title: "set_partner_data", data: data)
        showAlert(message: "Partner data set for Facebook with campaign info")
    }
    
    @IBAction func appendDeepLinkParameters(_ sender: UIButton) {
        let urlParameters = [
            "utm_source": "app",
            "utm_medium": "share",
            "utm_campaign": "user_referral",
            "user_id": customerIdTextField.text ?? "unknown"
        ]
        
        let data: [String: Any] = [
            "command_name": "appendparameterstodeeplinkurl",
            "url_contains": "myapp://",
            "url_parameters": urlParameters
        ]
        
        TealiumHelper.trackEvent(title: "append_deeplink_params", data: data)
        showAlert(message: "Deep link parameters appended for myapp:// URLs")
    }
    
    @IBAction func setCustomerId(_ sender: UIButton) {
        guard let customerId = customerIdTextField.text, !customerId.isEmpty else {
            showAlert(message: "Please enter a customer ID first")
            return
        }
        
        let data: [String: Any] = [
            "command_name": "setcustomerid",
            "af_customer_user_id": customerId
        ]
        
        TealiumHelper.trackEvent(title: "set_customer_id", data: data)
        showAlert(message: "Customer ID set: \(customerId)")
    }
    
    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "AppsFlyer Advanced", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
