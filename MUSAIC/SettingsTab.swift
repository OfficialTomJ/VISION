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
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 50)
                .padding(.leading)
            List {
                Section(header: Text("User Email")) {
                    Text(userEmail)
                        .padding()
                        .onAppear(perform: loadFirebaseUser)
                }
                
            }
            .listStyle(GroupedListStyle())
            
            Spacer()
            
            Button(action: signOut) {
                Text("Sign Out")
                    .foregroundColor(.red)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .shadow(radius: 5)
            }
            .padding(.bottom, 20)
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
