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

    @IBAction func setPhoneNumberTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Set Phone Number", message: "Enter phone number for AppsFlyer tracking", preferredStyle: .alert)

        ac.addTextField { textField in
            textField.placeholder = "Country code (e.g., 1)"
            textField.text = "1"
            textField.keyboardType = .phonePad
        }
        ac.addTextField { textField in
            textField.placeholder = "Phone number (e.g., 1234567890)"
            textField.text = "1234567890"
            textField.keyboardType = .phonePad
        }

        ac.addAction(UIAlertAction(title: "Set Phone", style: .default) { _ in
            guard let countryCode = ac.textFields?[0].text, !countryCode.isEmpty,
                  let phoneNumber = ac.textFields?[1].text, !phoneNumber.isEmpty else {
                return
            }

            TealiumHelper.trackEvent(title: "set_phone_number", data: [
                EcommerceMainViewController.countryCode: countryCode,
                EcommerceMainViewController.phoneNumber: phoneNumber
            ])

            let successAlert = UIAlertController(title: "Success", message: "Phone number set to: \(phoneNumber)", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
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
    static let phoneNumber = "phone_number"
    static let countryCode = "country_code"
}
