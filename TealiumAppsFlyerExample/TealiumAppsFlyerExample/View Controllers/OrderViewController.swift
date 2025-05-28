//
//  OrderViewController.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 7/19/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit

// Image Credit: https://www.flaticon.com/authors/smashicons 🙏
class OrderViewController: UIViewController {
    
    @IBOutlet weak var orderNumber: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        orderNumber.text = "Thank you! Your order number is: ORDABC\(Int.random(in: 0...1000) * 1000)"
        addValidationButtons()
    }
    
    private func addValidationButtons() {
        // Add buttons programmatically for demo purposes
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let validateOrderButton = UIButton(type: .system)
        validateOrderButton.setTitle("Validate Order Purchase", for: .normal)
        validateOrderButton.addTarget(self, action: #selector(validateOrderPurchase), for: .touchUpInside)
        
        let validateSubscriptionButton = UIButton(type: .system)
        validateSubscriptionButton.setTitle("Validate Subscription", for: .normal)
        validateSubscriptionButton.addTarget(self, action: #selector(validateSubscription), for: .touchUpInside)
        
        let trackReceiptButton = UIButton(type: .system)
        trackReceiptButton.setTitle("Track Receipt Validation", for: .normal)
        trackReceiptButton.addTarget(self, action: #selector(trackReceiptValidation), for: .touchUpInside)
        
        stackView.addArrangedSubview(validateOrderButton)
        stackView.addArrangedSubview(validateSubscriptionButton)
        stackView.addArrangedSubview(trackReceiptButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: orderNumber.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func validateOrderPurchase() {
        let orderPrice = Double.random(in: 15.99...199.99)
        let orderId = "ORD_\(Int.random(in: 10000...99999))"
        
        let data: [String: Any] = [
            "command_name": "validateandlogpurchase",
            "purchase_type": "one_time_purchase",
            "product_id": "premium_product_bundle",
            "price": String(format: "%.2f", orderPrice),
            "currency": "USD",
            "purchase_token": "receipt_\(orderId)",
            "additional_parameters": [
                "order_id": orderId,
                "category": "physical_goods",
                "payment_method": "credit_card"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "validate_order_purchase", data: data)
        showAlert(message: "Order purchase validated: $\(String(format: "%.2f", orderPrice))")
    }
    
    @objc func validateSubscription() {
        let subscriptionTypes = ["monthly", "yearly", "weekly"]
        let selectedType = subscriptionTypes.randomElement()!
        let price = selectedType == "yearly" ? 99.99 : (selectedType == "monthly" ? 9.99 : 2.99)
        
        let data: [String: Any] = [
            "command_name": "validateandlogpurchase",
            "purchase_type": "subscription",
            "product_id": "premium_\(selectedType)",
            "price": String(format: "%.2f", price),
            "currency": "USD",
            "purchase_token": "sub_receipt_\(Int.random(in: 10000...99999))",
            "additional_parameters": [
                "subscription_period": selectedType,
                "trial_period": selectedType == "monthly" ? "7_days" : "14_days",
                "auto_renew": true
            ]
        ]
        
        TealiumHelper.trackEvent(title: "validate_subscription", data: data)
        showAlert(message: "Subscription validated: \(selectedType.capitalized) $\(String(format: "%.2f", price))")
    }
    
    @objc func trackReceiptValidation() {
        let data: [String: Any] = [
            "command_name": "setadditionaldata",
            "additional_data": [
                "receipt_validation_status": "success",
                "receipt_id": "receipt_\(Int.random(in: 100000...999999))",
                "validation_timestamp": Date().timeIntervalSince1970,
                "store": "app_store"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "track_receipt_validation", data: data)
        showAlert(message: "Receipt validation tracked successfully")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Purchase Validation", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}

extension OrderViewController {
    static let screenClass = "screen_class"
    static let orderCouponCode = "order_coupon_code"
    static let orderId = "order_id"
    static let orderCurrency = "order_currency"
    static let orderTotal = "order_total"
}
