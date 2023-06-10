//
//  Navigation.swift
//  MUSAIC
//
//  Created by Kylie on 9/6/2023.
//

import SwiftUI
import FirebaseAuth

struct Navigation: View {
    @State private var selectedTab = 1
    @State private var showModal = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AlbumTab()
                .tabItem {
                    Image("headphones")
                }
                .tag(0)
            ContentView()
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
        .background(Color.black) // Set the background color of the TabView
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
        Navigation()
    }
}
