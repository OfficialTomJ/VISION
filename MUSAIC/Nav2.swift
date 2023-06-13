//
//  Nav2.swift
//  MUSAIC
//
//  Created by Kylie on 9/6/2023.
//

import SwiftUI

struct Nav2: View {
    var body: some View {
        TabView {
            Text("ALBUM TAB")
            .tabItem {
                Image("Album 1")
                Text("Album")
            }
            Text("THOUGHTS TAB")
                .tabItem{
                    Image("BMusicNote")
                    Text("Thoughts")
                }
            Text("SETTINGS TAB")
                .tabItem{
                    Image("BVector")
                    Text("Settings")
                }
        }
    }
    struct Nav2_Previews: PreviewProvider {
        static var previews: some View {
            Nav2()
        }
    }
}
