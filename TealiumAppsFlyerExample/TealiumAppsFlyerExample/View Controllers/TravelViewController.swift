//
//  TravelViewController.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 7/19/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit

class TravelViewController: UIViewController {

    
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var numberOfPassengersLabel: UILabel!
    @IBOutlet weak var numberOfRoomsLabel: UILabel!
    @IBOutlet weak var travelClassLabel: UISegmentedControl!
    
    var data = [String: Any]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TealiumHelper.trackScreen(self, name: "travel")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        originTextField.delegate = self
        destinationTextField.delegate = self
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        
        travelClassLabel.selectedSegmentIndex = 2
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
    
    @objc func share() {
        TealiumHelper.trackEvent(title: "share", data: [TravelViewController.contentType: "travel screen", TravelViewController.shareId: "traqwe123"])
        let vc = UIActivityViewController(activityItems: ["Travel"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    @IBAction func changeNumberOfPassengers(_ sender: UIStepper) {
        numberOfPassengersLabel.text = String(Int(sender.value))
        data[TravelViewController.numberOfAdults] = String(Int(sender.value))
        data[TravelViewController.numberOfChildren] = String(Int(sender.value))
    }
    
    @IBAction func changeNumberOfRooms(_ sender: UIStepper) {
        numberOfRoomsLabel.text = String(Int(sender.value))
        data[TravelViewController.rooms] = String(Int(sender.value))
    }
    
    @IBAction func changeTravelClass(_ sender: UISegmentedControl) {
        data[TravelViewController.travelClass] = sender.titleForSegment(at: sender.selectedSegmentIndex)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        guard let stringStartDate = startDateTextField.text else { return }
        guard let stringEndDate = endDateTextField.text else { return }
        guard let endDate = stringEndDate.toDate(with: "MMddyyyy") else { return }
        guard let startDate = stringStartDate.toDate(with: "MMddyyyy") else { return }
        let numberOfNights = endDate.daysFrom(earlierDate: startDate)
        data[TravelViewController.origin] = originTextField.text
        data[TravelViewController.destination] = destinationTextField.text
        data[TravelViewController.startDate] = stringStartDate
        data[TravelViewController.endDate] = stringEndDate
        data[TravelViewController.nights] = numberOfNights
        data[TravelViewController.suggestedDestinations] = ["Venice", "Amsterdam"]
        data[TravelViewController.destinationList] = ["Paris", "London", "Rome"]
        data[TravelViewController.hotelScore] = 4.3
        data[TravelViewController.preferredPriceRange] = [400,500]
        data[TravelViewController.preferredNumberStops] = [0,1]
        data[TravelViewController.ticketPrice] = [1000]
        TealiumHelper.trackEvent(title: "travelbooking", data: data)
    }
    
    @IBAction func resolveDeepLinksTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Resolve Deep Links", message: "Enter deep link URLs to be resolved by AppsFlyer (separated by commas)", preferredStyle: .alert)
        
        ac.addTextField { textField in
            textField.placeholder = "https://example.com/link1, https://example.com/link2"
            textField.text = "https://travel.example.com/booking/123, https://partners.example.com/offer/456"
        }
        
        ac.addAction(UIAlertAction(title: "Resolve Links", style: .default) { _ in
            guard let linksText = ac.textFields?[0].text, !linksText.isEmpty else {
                return
            }
            
            let deepLinks = linksText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            
            guard !deepLinks.isEmpty else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter at least one valid deep link URL", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }

            TealiumHelper.trackEvent(title: "resolve_deep_links", data: [
                TravelViewController.deepLinkUrls: deepLinks
            ])
            
            let successMessage = "AppsFlyer will resolve \(deepLinks.count) deep link(s):\n\(deepLinks.joined(separator: "\n"))"
            let successAlert = UIAlertController(title: "Deep Links Submitted", message: successMessage, preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

}

extension TravelViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        originTextField.resignFirstResponder()
        destinationTextField.resignFirstResponder()
        startDateTextField.resignFirstResponder()
        endDateTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension TravelViewController {
    static let contentType = "content_type"
    static let ticketPrice = "price"
    static let shareId = "share_id"
    static let rooms = "number_of_rooms"
    static let travelClass = "travel_class"
    static let origin = "travel_origin"
    static let destination = "travel_destination"
    static let startDate = "travel_start_date"
    static let endDate = "travel_end_date"
    static let nights = "number_of_nights"
    static let suggestedDestinations = "suggested_destinations"
    static let numberOfChildren = "number_children"
    static let numberOfAdults = "number_adults"
    static let hotelScore = "hotel_score"
    static let preferredPriceRange = "preferred_price_range"
    static let preferredNumberStops = "preferred_number_stops"
    static let destinationList = "destination_list"
    static let deepLinkUrls = "af_deep_link"
}
