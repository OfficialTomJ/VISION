//
//  ContentView.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 2/6/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    
    var body: some View {
        ZStack(alignment: .top){
            Image("Background")
                .resizable()
                .ignoresSafeArea()
            VStack (alignment: .center)
            {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.4, green: 0.6, blue: 0.9))
                    .frame(width: 300, height: 15)
                    .opacity(0.8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.5, green: 0.7, blue: 0.9))
                            .frame(width: 100, height: 15)
                            .opacity(0.9)
                            .overlay(Text("0")
                                .font(.caption)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.leading)))
                HStack(){
                    Text("What Inspired you today?")
                        .font(.title2)
                        .foregroundColor(Color.white)
                    Button(action: {}) {
                        Image("Reload")
                    }
                }.padding(.top, 300.0)
                HStack {
                    TextField("Enter thoughts", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .frame(width: 330)
                        .opacity(0.5)
                    Button(action: {}) {
                        Image("Send")
                    }
                }
                
            }.padding(.top, 50.0)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
