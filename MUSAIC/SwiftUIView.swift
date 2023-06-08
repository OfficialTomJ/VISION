//
//  AlbumView.swift
//  MUSAIC
//
//  Created by Khushbu Oswal on 8/6/2023.
//

import SwiftUI

struct AlbumView: View {
    @State private var offset = CGSize.zero
    var body: some View {
        ZStack(alignment: .top){
            Image("Background Image")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Image("Album 1") // Replace "Your Image" with the actual image name
                    .resizable()
                    .frame(width: 200, height: 200) // Adjust the size as needed
                    .padding(.top, 40.0)
                
                Text("You light Up my world")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                
                HStack {
                    Button(action: {
                        // Add your play button action here
                    }) {
                        Text("Play")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 10.0)
                        
                        
                    }
                    
                    Button(action: {
                        
                    }){
                        
                        Image("Play Circle")
                            .resizable()
                            .frame(width: 50, height:50)
                    }
                            
                            
                            
                        }
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing:20) {
                        HStack(spacing: 20) {
                        Image("New Image")
                        .resizable()
                        .frame(width: 200, height:200)
                    
                }
                
                
                
            }
            
            
            }
            
        }
    }
}
        struct AlbumView_Previews: PreviewProvider {
            static var previews: some View {
                AlbumView()
            }
        }

