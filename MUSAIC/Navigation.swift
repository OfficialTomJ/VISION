//
//  Navigation.swift
//  MUSAIC
//
//  Created by Kylie on 9/6/2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct Navigation: View {
    @State private var selectedTab = 1
    @State private var showModal = false
    
    @Binding var databaseRef: DatabaseReference
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AlbumTab(databaseRef: databaseRef, selectedTab: $selectedTab)
                .tabItem {
                    Label ("Album", systemImage: "photo")
                        .accentColor(.black)
                }
                .tag(0)
            ContentView(databaseRef: $databaseRef)
                .tabItem {
                    Label ("Thoughts", systemImage: "plus.bubble.fill")
                }
                .tag(1)
            SettingsTab()
                .tabItem {
                    Label ("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .onAppear() {UITabBar.appearance().backgroundColor = .lightText}
        .accentColor(.black) // Set the color of the selected tab
        .onAppear(perform: checkFirebaseUser)
        .sheet(isPresented: $showModal) {
            SignInView(email: .constant(""), password: .constant(""), isSignUp: .constant(false), signInAction: {})

        }
    }
    
    func checkFirebaseUser() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                showModal = false
            } else {
                showModal = true
            }
        }
    }
}

struct Navigation_Previews: PreviewProvider {
    static var previews: some View {
        let databaseRef = Binding.constant(Database.database().reference())
        Navigation(databaseRef: databaseRef)
    }
}
