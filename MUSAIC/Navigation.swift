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
                    Image("headphones")
                }
                .tag(0)
            
            ContentView(databaseRef: $databaseRef)
                .tabItem {
                    Image("BMusicNote")
                }
                .tag(1)
            
            SettingsTab()
                .tabItem {
                    Image("BVector")
                }
                .tag(2)
        }
        .accentColor(.red) // Set the color of the selected tab
        .background(Color.black)
        .onAppear(perform: checkFirebaseUser)
        .sheet(isPresented: $showModal) {
            SignInView()
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
