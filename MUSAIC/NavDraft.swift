//
//  NavDraft.swift
//  MUSAIC
//
//  Created by Kylie on 9/6/2023.
//

import SwiftUI

struct NavDraft: View {
    
    var body: some View {
        
        TabView {
                   AlbumTab()
                        .tabItem {
                            Image("Album1")
                        }
                   ContentView()
                        .tabItem {
                            Image("BMusicNote")
                        }
                    SettingsTab()
                        .tabItem {
                            Image("gear")
                        }
                }
            }
        }
    struct NavDraft_Previews: PreviewProvider {
        static var previews: some View {
            NavDraft()
        }
    }

