//
//  MapScreen.swift
//  Survale
//
//  Created by Sean Fillmore on 11/16/24.
//
import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

struct MapScreen: View {
    @ObservedObject var locationManager: LocationManager
    @State private var cameraRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var isCameraInitialized = false

    private func coordinatesAreEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D?) -> Bool {
        guard let rhs = rhs else { return false }
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    var body: some View {
        ZStack {
            if locationManager.permissionDenied {
                PermissionDeniedView()
            } else if let location = locationManager.currentLocation {
                MapView(usersLocations: locationManager.otherUsersLocations.values.filter { !coordinatesAreEqual($0, locationManager.currentLocation?.coordinate) }.map { UserLocation(coordinate: $0) }, cameraRegion: $cameraRegion)
                    .onAppear {
                        if !isCameraInitialized {
                            cameraRegion.center = location.coordinate
                            isCameraInitialized = true
                        }
                    }
                    .onChange(of: locationManager.currentLocation) { newLocation in
                        if !isCameraInitialized, let newLocation = newLocation {
                            cameraRegion.center = newLocation.coordinate
                            isCameraInitialized = true
                        }
                    }
            } else {
                LoadingView()  // Display loading view while waiting for location
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if let _ = locationManager.currentLocation {
                        Button(action: {
                            if let location = locationManager.currentLocation {
                                withAnimation {
                                    cameraRegion.center = location.coordinate
                                }
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
        }
        .alert(isPresented: $locationManager.permissionDenied) {
            Alert(
                title: Text("Location Access Denied"),
                message: Text("Please enable location permissions in settings."),
                primaryButton: .default(Text("Go to Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

struct PermissionDeniedView: View {
    var body: some View {
        VStack {
            Text("Location permissions are required.")
                .font(.title2)
                .padding()

            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

// Subview for Loading View
struct LoadingView: View {
    var body: some View {
        Text("Fetching location...")
            .font(.title)
            .foregroundColor(.gray)
    }
}

// Subview for Map View
struct UserLocation: Identifiable, Equatable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: UserLocation, rhs: UserLocation) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}

// Reusable Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct MapScreen_Previews: PreviewProvider {
    static var previews: some View {
        MapScreen(locationManager: LocationManager())
    }
}
