//
//  SurvaleApp.swift
//  Survale
//
//  Created by Sean Fillmore on 11/16/24.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct SurvaleApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                InitialView()
            }
        }
    }
}

struct InitialView: View {
    @State private var isLoggedIn = Auth.auth().currentUser != nil // Check if user is already logged in

    var body: some View {
        if isLoggedIn {
            MapScreen(locationManager: LocationManager()) // Navigate directly to MapScreen
        } else {
            LoginScreen()
        }
    }
}

