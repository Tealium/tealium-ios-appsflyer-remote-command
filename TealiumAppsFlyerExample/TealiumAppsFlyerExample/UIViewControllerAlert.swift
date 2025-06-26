//
//  UIViewController+Alert.swift
//  TealiumAppsFlyerExample
//
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Shows a simple alert with title, message and OK button
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    /// Shows a simple alert with just message and "Alert" as title
    /// - Parameter message: Alert message
    func showAlert(message: String) {
        showAlert(title: "Alert", message: message)
    }
} 