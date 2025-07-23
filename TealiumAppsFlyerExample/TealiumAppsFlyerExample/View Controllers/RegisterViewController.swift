//
//  RegisterViewController.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 7/18/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit

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
        // Add customer emails array to payload
        // Add email hash type of 3 to payload
        TealiumHelper.trackEvent(title: "user_register", data: [RegisterViewController.customerId: "ABC123", RegisterViewController.signUpMethod: "apple", RegisterViewController.customerEmails: customerEmails, RegisterViewController.emailHashType: 3])
    }

    @IBAction func setPhoneNumberTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Set Phone Number", message: "Enter your phone number for AppsFlyer tracking", preferredStyle: .alert)
        
        ac.addTextField { textField in
            textField.placeholder = "Phone number (e.g., +1234567890)"
            textField.keyboardType = .phonePad
            textField.text = "+1234567890"
        }
        
        ac.addAction(UIAlertAction(title: "Set Phone Number", style: .default) { _ in
            guard let phoneNumber = ac.textFields?[0].text, !phoneNumber.isEmpty else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter a valid phone number", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            
            TealiumHelper.trackEvent(title: "set_phone_number", data: [
                RegisterViewController.phoneNumber: phoneNumber
            ])
            
            let successAlert = UIAlertController(title: "Phone Number Set", message: "AppsFlyer phone number set to: \(phoneNumber)", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
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
    static let phoneNumber = "phone_number"
}
