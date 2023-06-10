//
//  AlbumView.swift
//  MUSAIC
//
//  Created by Khushbu Oswal on 8/6/2023.
//

import SwiftUI

struct AlbumTab: View {
    @State private var offset = CGSize.zero
    
    let albums = ["Album 1", "Album 2","New Image", "New Album","Album 3"]
    var body: some View {
        ZStack(alignment: .top){
            Image("Background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Image("sample")
                    .resizable()
                    .frame(width: 200, height: 200)
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
                        
                        Image("Play")
                            .resizable()
                            .frame(width: 50, height:50)
                    }
                    
                    
                    
                }
                .padding(.bottom, 0.0)
                
                
                Image("Bigger line") // Replace "Line" with the name of your line image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 2)
                                    .padding(.vertical, 30)
                
                
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: gridItems(), spacing: 20) {
                        ForEach(albums, id: \.self) {album in
                                Button(action: {
                                    
                                    
                                }) {
                                    Image("sample")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                
                                    
                               
                                }
                            }
                            
                        }
                }
                
            }
        }
    }
    private func gridItems() -> [GridItem] {
        let gridItemSize: CGFloat = 100
        let spacing: CGFloat = 20
        let screenWidth = UIScreen.main.bounds.width
        let columns = Int(screenWidth / (gridItemSize + spacing))
        return Array(repeating: GridItem(.fixed(gridItemSize), spacing: spacing), count: columns)
    }
}
    struct AlbumView_Previews: PreviewProvider {
        static var previews: some View {
            AlbumTab()
        }
    }
