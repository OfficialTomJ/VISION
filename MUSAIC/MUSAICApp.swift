//
//  MUSAICApp.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 2/6/2023.
//

import SwiftUI
import Firebase
import FirebaseDatabase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MUSAICApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isUserSignedIn = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false

    var body: some Scene {
        WindowGroup {
            if isUserSignedIn {
                let databaseRef = Binding.constant(Database.database().reference())
                Navigation(databaseRef: databaseRef)
                    .onAppear {
                        observeAuthState()
                    }
            } else {
                SignInView(email: $email, password: $password, isSignUp: $isSignUp, signInAction: signIn)
                    .onAppear {
                        observeAuthState()
                    }
            }
        }
    }

    func signIn() {
        // Call the signInAction closure with the entered email, password, and sign-up flag
        signInAction(email, password, isSignUp)
    }

    func signInAction(_ email: String, _ password: String, _ isSignUp: Bool) {
        if isSignUp {
            // Sign up a new user
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Sign Up Error: \(error.localizedDescription)")
                } else {
                    isUserSignedIn = true
                    print("Sign Up Successful")
                }
            }
        } else {
            // Sign in an existing user
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Sign In Error: \(error.localizedDescription)")
                } else {
                    isUserSignedIn = true
                    print("Sign In Successful")
                }
            }
        }
    }

    func observeAuthState() {
        Auth.auth().addStateDidChangeListener { _, user in
            isUserSignedIn = user != nil
        }
    }
}
