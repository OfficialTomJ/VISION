//
//  Navigation.swift
//  MUSAIC
//
//  Created by Kylie on 9/6/2023.
//

import SwiftUI

struct Navigation: View {
    @State private var selectedTab = 1
    
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
    }
}

struct Navigation_Previews: PreviewProvider {
    static var previews: some View {
        Navigation()
    }
}
