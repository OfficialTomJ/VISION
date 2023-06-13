//
//  SettingsTab.swift
//  MUSAIC
//
//  Created by Kylie on 9/6/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct SettingsTab: View {
    @State private var userEmail: String = ""
    @State private var showingConfirmation = false
    
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
                Section(header: Text("Clear Data")) {
                                    Button(action: {
                                        showingConfirmation = true
                                    }) {
                                        Text("Delete All Thoughts")
                                            .foregroundColor(.red)
                                            .font(.headline)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .alert(isPresented: $showingConfirmation) {
                                                            Alert(
                                                                title: Text("Delete Thoughts"),
                                                                message: Text("Are you sure you want to delete all your thoughts? This action cannot be undone."),
                                                                primaryButton: .destructive(Text("Delete")) {
                                                                    deleteThoughts()
                                                                },
                                                                secondaryButton: .cancel()
                                                            )
                                                        }
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
    
    func deleteThoughts() {
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            
            let userID = currentUser.uid
            let databaseRef = Database.database().reference().child(userID).child("thoughts")
            
            databaseRef.removeValue { error, _ in
                if let error = error {
                    print("Error deleting thoughts: \(error)")
                } else {
                    print("Thoughts deleted successfully.")
                }
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
