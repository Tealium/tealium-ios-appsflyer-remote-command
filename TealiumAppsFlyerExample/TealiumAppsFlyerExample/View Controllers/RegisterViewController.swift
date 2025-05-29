//
//  RegisterViewController.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 7/18/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit
import TealiumAppsFlyer

// Image Credit: https://www.flaticon.com/authors/flat-icons 🙏
class RegisterViewController: UIViewController {

    // Add customerEmail textField
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    var customerEmails = [String]()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TealiumHelper.trackScreen(self, name: "register")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
        email.delegate = self
        username.delegate = self
        password.delegate = self
    }

    @IBAction func onRegister(_ sender: Any) {
        if let customerEmail = email.text {
            customerEmails.append(customerEmail)
        }
        // Use EmailHashType.sha256 instead of magic number
        TealiumHelper.trackEvent(title: "user_register", data: [
            RegisterViewController.customerId: "ABC123",
            RegisterViewController.signUpMethod: "apple",
            RegisterViewController.customerEmails: customerEmails,
            RegisterViewController.emailHashType: AppsFlyerConstants.EmailHashType.sha256.rawValue
        ])
    }

}

extension RegisterViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        email.resignFirstResponder()
        username.resignFirstResponder()
        password.resignFirstResponder()
    }
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension RegisterViewController {
    static let customerId = "customer_id"
    static let signUpMethod = "signup_method"
    static let customerEmails = "customer_emails"
    static let emailHashType = "email_hash_type"
}
