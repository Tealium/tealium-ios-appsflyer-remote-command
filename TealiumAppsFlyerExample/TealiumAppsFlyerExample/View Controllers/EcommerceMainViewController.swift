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
            TealiumHelper.trackView(title: "category", data: [CategoryViewController.screenClass: "CategoryViewController", CategoryViewController.categoryName: "appliances"])
        case 2:
            hideAllViews(except: productView)
            TealiumHelper.trackView(title: "product", data: [ProductViewController.screenClass: "ProductViewController", ProductViewController.productId: ["PROD\(Int.random(in: 1...1000))"],
                                                             ProductViewController.productPrice: [100],
                                                             ProductViewController.productName: ["Fridge"],
                                                             ProductViewController.productCategory: ["appliances"]])
        case 3:
            hideAllViews(except: checkoutView)
            TealiumHelper.trackView(title: "checkout", data: [CheckoutViewController.screenClass: "CheckoutViewController"])
        case 4:
            hideAllViews(except: orderView)
            let orderData: [String: Any] = [OrderViewController.orderId: Int.random(in: 0...1000) * 1000, OrderViewController.orderCurrency: "USD", OrderViewController.orderTotal: Int.random(in: 0...1000), OrderViewController.screenClass: "OrderViewController"]
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
    static let contentType = "content_type"
    static let shareId = "share_id"
    static let signUpMethod = "signup_method"
}
