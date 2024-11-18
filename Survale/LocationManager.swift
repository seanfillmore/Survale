//
//  LocationManager.swift
//  Survale
//
//  Created by Sean Fillmore on 11/16/24.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore() // Firestore reference

    @Published var currentLocation: CLLocation? = CLLocation(latitude: 37.7749, longitude: -122.4194) // Default: San Francisco
    @Published var permissionDenied = false
    @Published var otherUsersLocations: [String: CLLocationCoordinate2D] = [:] // Other users' locations

    override init() {
        super.init()
        locationManager.delegate = self // Conform to CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Check authorization status on initialization
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.permissionDenied = true
            }
        @unknown default:
            DispatchQueue.main.async {
                self.permissionDenied = true
            }
        }

        // Start listening for mock user locations from Firestore
        listenForMockUserLocations()
    }

    // Save current user's location to Firestore
    private func saveLocationToFirestore(location: CLLocation) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user.")
            return
        }

        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": FieldValue.serverTimestamp() // Use server time
        ]

        db.collection("locations").document(userId).setData(locationData) { error in
            if let error = error {
                print("Error saving location: \(error.localizedDescription)")
            } else {
                print("Location saved successfully.")
            }
        }
    }

    // Listen for other users' locations from Firestore
    private func listenForMockUserLocations() {
        db.collection("locations").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching user locations: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var updatedLocations: [String: CLLocationCoordinate2D] = [:]
            for document in documents {
                if let latitude = document.data()["latitude"] as? Double,
                   let longitude = document.data()["longitude"] as? Double {
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    updatedLocations[document.documentID] = location
                }
            }

            DispatchQueue.main.async {
                self.otherUsersLocations = updatedLocations
            }
        }
    }

    // CLLocationManagerDelegate method: Called when the location manager updates locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
            self.saveLocationToFirestore(location: location) // Save updated location to Firestore
        }
    }

    // CLLocationManagerDelegate method: Called when authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.permissionDenied = false
                self.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                self.permissionDenied = true
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            @unknown default:
                self.permissionDenied = true
            }
        }
    }

    // CLLocationManagerDelegate method: Called if location manager fails with error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
