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
    private func updateCameraRegion(with location: CLLocation) {
        cameraRegion.center = location.coordinate
    }
    
    private func coordinatesAreEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D?) -> Bool {
        guard let rhs = rhs else { return false }
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    @ObservedObject var locationManager: LocationManager // Shared LocationManager instance
    @State private var cameraRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ZStack {
            // Show appropriate content based on location permissions
            if locationManager.permissionDenied {
                PermissionDeniedView()
            } else if let location = locationManager.currentLocation {
                Map(
                    coordinateRegion: $cameraRegion,
                    interactionModes: .all,
                    showsUserLocation: true,
                    annotationItems: locationManager.otherUsersLocations.values.filter {
                        !coordinatesAreEqual($0, locationManager.currentLocation?.coordinate)
                    }.map { UserLocation(coordinate: $0) }
                ) { userLocation in
                    MapAnnotation(coordinate: userLocation.coordinate) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                    }
                }
                .onAppear {
                    if cameraRegion.center.latitude == 0.0 && cameraRegion.center.longitude == 0.0 {
                        cameraRegion.center = location.coordinate
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
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

// Preview for MapScreen
struct MapScreen_Previews: PreviewProvider {
    static var previews: some View {
        MapScreen(locationManager: LocationManager())
    }
}

// Subview for Permission Denied Message
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
