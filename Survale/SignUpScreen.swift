//
//  SignUpScreen.swift
//  Survale
//
//  Created by Sean Fillmore on 11/16/24.
//
import SwiftUI
import FirebaseAuth

struct SignUpScreen: View {
    @Environment(\.presentationMode) var presentationMode // For dismissing the screen
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signUpError: String? = nil
    @State private var showLoginSuccessMessage: Bool = false // For showing a success alert

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Email TextField
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal, 20)

            // Password TextField
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)

            // Sign Up Button
            Button(action: {
                signUp()
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)

            // Error Message
            if let error = signUpError {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }

            // Back to Login Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back to Login")
                    .foregroundColor(.blue)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
        .alert(isPresented: $showLoginSuccessMessage) {
                    Alert(
                        title: Text("Sign-Up Successful"),
                        message: Text("You have successfully created an account. Please log in."),
                        dismissButton: .default(Text("OK")) {
                            // Dismiss the Sign-Up screen when the alert is dismissed
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
    }

    private func signUp() {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    signUpError = error.localizedDescription
                } else {
                    signUpError = nil
                    print("User signed up successfully: \(authResult?.user.email ?? "")")
                    showLoginSuccessMessage = true // Trigger the success alert
                }
            }
        }
}

struct SignUpScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen()
    }
}
