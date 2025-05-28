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
        TealiumHelper.trackEvent(title: "travel_order", data: data)
    }
    
    // MARK: - New Travel Booking Features
    @IBAction func bookTravelWithAdvancedData(_ sender: UIButton) {
        guard let origin = originTextField.text, !origin.isEmpty,
              let destination = destinationTextField.text, !destination.isEmpty else {
            showAlert(message: "Please enter origin and destination")
            return
        }
        
        let travelPrice = Double.random(in: 299.99...2999.99)
        
        let data: [String: Any] = [
            "command_name": "travelbooking",
            "af_destination_a": origin,
            "af_destination_b": destination,
            "af_departing_departure_date": startDateTextField.text ?? "",
            "af_returning_departure_date": endDateTextField.text ?? "",
            "af_num_adults": Int(numberOfPassengersLabel.text ?? "1") ?? 1,
            "af_num_children": 0,
            "af_num_infants": 0,
            "af_class": travelClassLabel.titleForSegment(at: travelClassLabel.selectedSegmentIndex) ?? "Economy",
            "af_city": destination,
            "af_country": "Unknown",
            "af_revenue": travelPrice,
            "af_currency": "USD",
            "additional_parameters": [
                "booking_source": "mobile_app",
                "trip_type": "round_trip"
            ]
        ]
        
        TealiumHelper.trackEvent(title: "advanced_travel_booking", data: data)
        showAlert(message: "Travel booked: \(origin) → \(destination) $\(String(format: "%.2f", travelPrice))")
    }
    
    @IBAction func trackLocationCoordinates(_ sender: UIButton) {
        // Simulate getting current location
        let locations = [
            ("New York", 40.7128, -74.0060),
            ("Paris", 48.8566, 2.3522),
            ("Tokyo", 35.6762, 139.6503),
            ("London", 51.5074, -0.1278),
            ("Sydney", -33.8688, 151.2093)
        ]
        
        let randomLocation = locations.randomElement()!
        
        let data: [String: Any] = [
            "command_name": "locationcoordinates",
            "af_lat": randomLocation.1,
            "af_long": randomLocation.2,
            "af_city": randomLocation.0
        ]
        
        TealiumHelper.trackEvent(title: "track_location_coordinates", data: data)
        showAlert(message: "Location tracked: \(randomLocation.0) (\(randomLocation.1), \(randomLocation.2))")
    }
    
    @IBAction func trackLocationChanged(_ sender: UIButton) {
        let newLocation = destinationTextField.text ?? "Paris"
        
        let data: [String: Any] = [
            "command_name": "locationchanged",
            "af_city": newLocation,
            "af_region": "Europe",
            "af_country": "France"
        ]
        
        TealiumHelper.trackEvent(title: "location_changed", data: data)
        showAlert(message: "Location changed to: \(newLocation)")
    }
    
    @IBAction func updateTravelPreferences(_ sender: UIButton) {
        let preferences: [String: Any] = [
            "preferred_airlines": ["Delta", "United", "American"],
            "seat_preference": "Window",
            "meal_preference": "Vegetarian",
            "frequent_flyer_number": "FF123456789",
            "travel_insurance": true
        ]
        
        let data: [String: Any] = [
            "command_name": "update",
            "additional_parameters": preferences
        ]
        
        TealiumHelper.trackEvent(title: "update_travel_preferences", data: data)
        showAlert(message: "Travel preferences updated")
    }
    
    // MARK: - Helper Method
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Travel", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
    static let passengers = "number_of_passengers"
    static let rooms = "number_of_rooms"
    static let travelClass = "travel_class"
    static let origin = "travel_origin"
    static let destination = "travel_destination"
    static let startDate = "travel_start_date"
    static let endDate = "travel_end_date"
    static let nights = "number_of_nights"
    static let suggestedDestinations = "suggested_desitnations"
    static let numberOfChildren = "number_children"
    static let numberOfAdults = "number_adults"
    static let hotelScore = "hotel_score"
    static let preferredPriceRange = "preferred_price_range"
    static let preferredNumberStops = "preferred_number_stops"
    static let destinationList = "destination_list"
}
