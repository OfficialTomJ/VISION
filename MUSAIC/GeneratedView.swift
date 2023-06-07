//
//  GeneratedView.swift
//  MUSAIC
//
//  Created by Suleman Dawood on 7/6/2023.
//

import SwiftUI

struct GeneratedView: View {
    
    @State private var isPlaying = false
    
    var body: some View {
        ZStack(alignment: .top){
            Image("Background")
                .resizable()
                .frame(width: 450,height: 1000)
                .ignoresSafeArea()
            ScrollView{
                VStack(alignment: .center) {
                    HStack(){
                        Spacer()
                        Button(action: {}) {
                            Image("upload")
                                .resizable()
                                .frame(width: 20, height: 27)
                        }.padding(.trailing, 60)
                    }
                    Text("24 May 2023")
                        .font(.title3)
                        .foregroundColor(Color.white)
                    Image("sample")
                        .resizable()
                        .frame(width: 300, height: 300)
                    HStack {
                        VStack{
                            Image("Album 1")
                                .resizable()
                                .padding()
                                .frame(width: 72, height: 90)
                            Button(action: {
                                        isPlaying.toggle()
                                    }) {
                                        Image(isPlaying ? "Pause" : "play")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                    }
                                    .padding(.bottom, 20.0)
                        }
                       
                        VStack(alignment: .leading) {
                            Text(album.title)
                                .font(.title)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 2.0)
                            Text(album.caption)
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                                .italic()
                                .padding(.bottom, 10.0)
                        }
                    }
                   
                    Text(album.shortReflection)
                        .font(.body)
                        .foregroundColor(Color.white)
                        .padding([.leading, .trailing], 40.0)
                    HStack{
                        Image("meditation 1")
                            .resizable()
                            .padding()
                            .frame(width: 80, height: 90)
                        VStack(alignment: .leading) {
                            Text("LIST OF SONGS WITH SPOTIFY LINK HERE")
                                .font(.title)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 2.0)
                        }
                    }
                    Group {
                       
                        Text(album.mindRecom)
                            .font(.title)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 10.0)
                        Text(album.mindDescRecom)
                            .font(.body)
                            .foregroundColor(Color.white)
                            .padding([.leading, .trailing], 40.0)
                            .multilineTextAlignment(.leading)
                        Text("Challenge Yourself")
                            .font(.title)
                            .foregroundColor(Color.white)
                            .padding(.vertical, 2.0)
                    }
                    Group {
                        ForEach(album.goals, id: \.self) { goal in
                                        Text(goal)
                                    }
                    }.font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 2)
                        .padding(.leading,40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 1, green: 1, blue: 1))
                            .frame(width: 200, height: 40)
                            .opacity(0.3)
                        Button(action: {}) {
                            Text("Create New Album")
                                .foregroundColor(Color.white)
                                .foregroundColor(Color.white)
                        }
                    }
                    .padding(.top)
                }.padding(.vertical, 120)
            }.padding()
            
        }
    }
}


var album = Album(
    title: "Vibrant Transitions",
    caption: "Embrace the Colors of Life",
    shortReflection: "Vibrant Transitions is a musical journey...",
    mindRecom: "Mindful Mornings",
    mindDescRecom: "Start your day with mindfulness exercises...",
    goals: [
        "Practice guitar solos for the Friday band rehearsal.",
        "Initiate a conversation with another classmate to expand social connections."
    ]
)


struct GeneratedView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratedView()
    }
}
