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
        Map(
            coordinateRegion: $cameraRegion,
            interactionModes: .all,
            showsUserLocation: true,
            annotationItems: usersLocations
        ) { userLocation in
            MapAnnotation(coordinate: userLocation.coordinate) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
            }
        }
        .ignoresSafeArea()
    }
}
