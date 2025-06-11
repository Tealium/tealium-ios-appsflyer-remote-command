//
//  EcommerceMainViewController.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 7/19/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit

// Image Credit: https://www.flaticon.com/authors/freepik 🙏
class EcommerceMainViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var navigationControl: UISegmentedControl!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var checkoutView: UIView!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var homeStackView: UIStackView!

    var views = [UIView]()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TealiumHelper.trackScreen(self, name: "ecommerce_home")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        views = [homeStackView, orderView, checkoutView, productView, categoryView]
        hideAllViews(except: homeStackView)
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        enableNotifications()
    }

    @objc func share() {
        TealiumHelper.trackEvent(title: "share", data: [EcommerceMainViewController.contentType: "shop home screen", EcommerceMainViewController.shareId: "shopqwe123"])
        let vc = UIActivityViewController(activityItems: ["Shop"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    @IBAction func navigationSelection(_ sender: UISegmentedControl) {
        switch navigationControl.selectedSegmentIndex {
        case 1:
            hideAllViews(except: categoryView)
            TealiumHelper.trackView(title: "category", data: [CategoryViewController.screenClass: "CategoryViewController", CategoryViewController.categoryName: "appliances", CategoryViewController.productId: CategoryViewController.products])
        case 2:
            hideAllViews(except: productView)
            TealiumHelper.trackView(title: "product", data: [ProductViewController.screenClass: "ProductViewController", ProductViewController.productId: ["PROD\(Int.random(in: 1...1000))"],
                                                             ProductViewController.productQuantity: [1],
                                                             ProductViewController.productPrice: [200],
                                                             ProductViewController.productName: ["Fridge"],
                                                             ProductViewController.productCategory: ["appliances"]])
        case 3:
            hideAllViews(except: checkoutView)
            TealiumHelper.trackView(title: "checkout", data: [CheckoutViewController.screenClass: "CheckoutViewController"])
        case 4:
            hideAllViews(except: orderView)
            let orderData: [String: Any] = [
                ProductViewController.productId: ["PROD\(Int.random(in: 1...1000))", "PROD\(Int.random(in: 1...1000))"],
                ProductViewController.productQuantity: [1, 2],
                ProductViewController.productPrice: [200, 300],
                ProductViewController.productName: ["Fridge", "Television"],
                ProductViewController.productCategory: ["appliances", "electronics"],
                OrderViewController.orderId: Int.random(in: 0...1000) * 1000,
                OrderViewController.orderCurrency: "USD",
                OrderViewController.orderCouponCode: "Summer2020",
                OrderViewController.orderTotal: 800,
                OrderViewController.screenClass: "OrderViewController"]
            TealiumHelper.trackView(title: "order", data: orderData)
        default:
            hideAllViews(except: homeStackView)
        }
    }

    func enableNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showOrder), name: Notification.Name(CheckoutViewController.placedOrderClicked), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProduct), name: Notification.Name(CategoryViewController.productClicked), object: nil)
    }

    @IBAction func signUp(_ sender: Any) {
        TealiumHelper.trackEvent(title: "email_signup", data: [EcommerceMainViewController.signUpMethod: "shop homepage"])
        let ac = UIAlertController(title: "Congrats!", message: "You're all signed up. You will receive discounts right away!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @IBAction func trackLocation(_ sender: Any) {
        TealiumHelper.trackEvent(title: "track_location", data: [EcommerceMainViewController.latitude: 32.802353, EcommerceMainViewController.longitude: -117.241676])
        let ac = UIAlertController(title: "Tracking Location", message: "Tracking your location as San Diego ☀️🏖, enjoy the beach!", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    // MARK: - New Privacy & GDPR Features
    @IBAction func setUserEmails(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Email Required", message: "Please enter an email address first")
            return
        }
        
        let data: [String: Any] = [
            "command_name": "setuseremails",
            "customer_emails": [email],
            "email_hash_type": "sha256"
        ]
        
        TealiumHelper.trackEvent(title: "set_user_emails", data: data)
        showAlert(title: "Email Set", message: "User email set: \(email)")
    }
    
    @IBAction func setGDPRConsent(_ sender: UIButton) {
        let alert = UIAlertController(title: "GDPR Consent", message: "Do you consent to data processing?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Accept All", style: .default) { _ in
            let data: [String: Any] = [
                "command_name": "setdmaconsent",
                "gdpr_applies": true,
                "consent_for_data_usage": true,
                "consent_for_ads_personalization": true,
                "consent_for_ad_storage": true
            ]
            TealiumHelper.trackEvent(title: "gdpr_consent_accept", data: data)
            self.showAlert(title: "Consent", message: "All consents granted")
        })
        
        alert.addAction(UIAlertAction(title: "Decline", style: .destructive) { _ in
            let data: [String: Any] = [
                "command_name": "setdmaconsent",
                "gdpr_applies": true,
                "consent_for_data_usage": false,
                "consent_for_ads_personalization": false,
                "consent_for_ad_storage": false
            ]
            TealiumHelper.trackEvent(title: "gdpr_consent_decline", data: data)
            self.showAlert(title: "Consent", message: "All consents declined")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func resolveDeepLinks(_ sender: UIButton) {
        let deepLinks = [
            "myapp://products/electronics",
            "myapp://offers/summer2024", 
            "myapp://cart/checkout"
        ]
        
        let data: [String: Any] = [
            "command_name": "resolvedeeplinkurls",
            "af_deep_link": deepLinks
        ]
        
        TealiumHelper.trackEvent(title: "resolve_deep_links", data: data)
        showAlert(title: "Deep Links", message: "Resolved \(deepLinks.count) deep link URLs")
    }
    
    @IBAction func stopTracking(_ sender: UIButton) {
        let alert = UIAlertController(title: "Stop Tracking", message: "Are you sure you want to stop AppsFlyer tracking?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes, Stop", style: .destructive) { _ in
            let data: [String: Any] = [
                "command_name": "disabletracking",
                "stop_tracking": true
            ]
            TealiumHelper.trackEvent(title: "stop_tracking", data: data)
            self.showAlert(title: "Tracking Stopped", message: "AppsFlyer tracking has been disabled")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Helper Method
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func hideAllViews(except: UIView) {
        views.forEach { view in
            if view == except {
                view.isHidden = false
            } else {
                view.isHidden = true
            }
        }
    }

    @objc func showProduct() {
        navigationControl.selectedSegmentIndex = 2
        hideAllViews(except: productView)
    }

    @objc func showOrder() {
        navigationControl.selectedSegmentIndex = 4
        hideAllViews(except: orderView)
    }

}

extension EcommerceMainViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension EcommerceMainViewController {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let contentType = "content_type"
    static let shareId = "share_id"
    static let signUpMethod = "signup_method"
}
