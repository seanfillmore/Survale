//
//  MapView.swift
//  Survale
//
//  Created by Sean Fillmore on 11/17/24.
//
import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    let usersLocations: [UserLocation]
    @Binding var cameraRegion: MKCoordinateRegion

    var body: some View {
        if #available(iOS 17.0, *) {
            Map(
                coordinateRegion: $cameraRegion,
                interactionModes: .all,
                annotationItems: usersLocations
            ) { userLocation in
                MapMarker(coordinate: userLocation.coordinate)
            }
            .ignoresSafeArea()
        } else {
            // Fallback for iOS 16
            Map(coordinateRegion: .constant(
                MKCoordinateRegion(
                    center: usersLocations.first?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            ),
            annotationItems: usersLocations) { userLocation in
                MapMarker(coordinate: userLocation.coordinate)
            }
            .ignoresSafeArea()
        }
    }
}