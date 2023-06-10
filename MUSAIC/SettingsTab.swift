//
//  SettingsTab.swift
//  MUSAIC
//
//  Created by Kylie on 9/6/2023.
//

import SwiftUI
import FirebaseAuth

struct SettingsTab: View {
    @State private var userEmail: String = ""
    
    var body: some View {
        VStack {
            Text("SETTINGS TAB 🔩")
            Text("User Email: \(userEmail)")
                .padding()
                .onAppear(perform: loadFirebaseUser)
            
            Button(action: signOut) {
                Text("Sign Out")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    func loadFirebaseUser() {
        if let currentUser = Auth.auth().currentUser {
            let email = currentUser.email
            userEmail = email ?? "N/A"
        } else {
            userEmail = "Not signed in"
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
            // Update the userEmail property
            userEmail = "Not signed in"
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
    }
}
