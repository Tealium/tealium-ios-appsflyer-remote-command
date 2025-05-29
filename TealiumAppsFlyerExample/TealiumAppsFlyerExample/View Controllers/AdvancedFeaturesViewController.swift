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
    
    // MARK: - Customer ID Actions
    @IBAction func setCustomerIdAndLogSession(_ sender: UIButton) {
        guard let customerId = customerIdTextField.text, !customerId.isEmpty else {
            showAlert(message: "Please enter a customer ID")
            return
        }
        
        let data: [String: Any] = [
            "command_name": "setcustomeridandlogsession",
            "customer_id": customerId
        ]
        
        TealiumHelper.trackEvent(title: "set_customer_id_and_log_session", data: data)
        showAlert(message: "Customer ID set and session logged: \(customerId)")
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
            "purchase_token": "sample_receipt_token_123",
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
    
    // MARK: - Additional Features
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
        let alert = UIAlertController(title: "AppsFlyer Advanced", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
