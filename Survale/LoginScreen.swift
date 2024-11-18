//
//  LoginScreen.swift
//  Survale
//
//  Created by Sean Fillmore on 11/16/24.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showForgotPassword: Bool = false
    @State private var showSignUpScreen: Bool = false
    @State private var loginError: String? = nil
    @State private var navigateToMapScreen: Bool = false
    @State private var isLoading: Bool = false
    @StateObject private var locationManager = LocationManager() // Preserve LocationManager instance

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)

            EmailTextField(email: $email)
            PasswordTextField(password: $password)

            Button(action: {
                showForgotPassword = true
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)

            if isLoading {
                ProgressView()
                    .padding()
            } else {
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            }

            NavigationLink(
                destination: SignUpScreen(),
                isActive: $showSignUpScreen
            ) {
                Button(action: {
                    showSignUpScreen = true
                }) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }
            }

            NavigationLink(
                destination: MapScreen(locationManager: locationManager), // Pass LocationManager
                isActive: $navigateToMapScreen
            ) {
                EmptyView()
            }

            if let error = loginError {
                ErrorMessageView(error: error)
            }

            Spacer()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordScreen()
        }
    }

    // Login Function (Firebase Auth)
    private func login() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                loginError = error.localizedDescription
            } else {
                loginError = nil
                navigateToMapScreen = true // Trigger navigation
            }
        }
    }
}

// Subview for Email TextField
struct EmailTextField: View {
    @Binding var email: String

    var body: some View {
        TextField("Email", text: $email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding(.horizontal, 20)
            .accessibility(label: Text("Email Address"))
    }
}

// Subview for Password TextField
struct PasswordTextField: View {
    @Binding var password: String

    var body: some View {
        SecureField("Password", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 20)
            .accessibility(label: Text("Password"))
    }
}

// Subview for Error Message
struct ErrorMessageView: View {
    let error: String

    var body: some View {
        Text(error)
            .foregroundColor(.red)
            .padding(.top, 10)
            .accessibility(label: Text("Error Message: \(error)"))
    }
}

struct ForgotPasswordScreen: View {
    var body: some View {
        Text("Forgot Password Screen")
            .font(.title)
            .padding()
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
