//
//  GeneratedView.swift
//  MUSAIC
//
//  Created by Suleman Dawood on 7/6/2023.
//

import SwiftUI
import Firebase

struct GeneratedView: View {
    
    let databaseRef: DatabaseReference
    
    let jsonString: String
    let albumArtworkURL: String
    
    @State private var isPlaying = false
    
    @State private var album: Album
    
    init(databaseRef: DatabaseReference) {
        self.databaseRef = databaseRef
        self.jsonString = ""
        self.albumArtworkURL = ""
        
        _album = State(initialValue: Album(
            URL: "",
            title: "",
            caption: "",
            shortReflection: "",
            mindRecom: "",
            mindDescRecom: "",
            goals: [""]
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("Blur")
                .resizable()
                .frame(width: 450,height: 1000)
                .ignoresSafeArea(.all)
            ScrollView {
                VStack(alignment: .center) {
                    VStack(alignment: .center) {
                        Text("24 May 2023")
                            .font(.title3)
                            .foregroundColor(Color.white)
                        AsyncImage(url: URL(string: album.URL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .padding(.bottom)
                                    .frame(width: 300, height: 300)
                            case .failure(let error):
                                Text("Failed to load image: \(error.localizedDescription)")
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    HStack {
                        
                        Image("Album")
                            .resizable()
                            .padding()
                            .frame(width: 72, height: 90)
                        
                        VStack(alignment: .leading) {
                            Text(album.title)
                                .font(.title)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 5.0)
                            Text(album.caption)
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.leading)
                                .italic()
                                .padding(.bottom, 10.0)
                        }
                        Spacer()
                    }
                    .padding(.leading, 35.0)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white)
                            .opacity(0.2)
                        HStack {
                            Spacer()
                            Button(action: {
                                isPlaying.toggle()
                            }) {
                                Image(isPlaying ? "Pause" : "Play")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                            .padding(.vertical, 15.0)
                            Spacer()
                            Button(action: {}) {
                                Image("Upload")
                                    .resizable()
                                    .frame(width: 35, height: 50)
                            }
                            Spacer()
                        }
                    }
                    .padding(.bottom, 35)
                    
                    Text("Summary")
                        .font(.body)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding([.leading, .trailing], 45.0)
                    Text(album.shortReflection)
                        .font(.body)
                        .foregroundColor(Color.white)
                        .padding([.leading, .trailing], 30.0)
                    HStack{
                        Image("meditation")
                            .resizable()
                            .padding()
                            .frame(width: 80, height: 85)
                        Text(album.mindRecom)
                            .font(.title)
                            .foregroundColor(Color.white)
                        Spacer()
                    }.padding(.leading, 35.0)
                    Group {
                        
                        Text(album.mindDescRecom)
                            .font(.body)
                            .foregroundColor(Color.white)
                            .padding([.leading, .trailing], 45.0)
                            .multilineTextAlignment(.leading)
                        HStack{
                            Image("Goals")
                                .resizable()
                                .padding()
                                .frame(width: 75, height: 75)
                            Text("Challenge Yourself")
                                .font(.title)
                                .foregroundColor(Color.white)
                                .padding(.vertical, 2.0)
                            Spacer()
                        }.padding(.leading, 35.0)
                        
                    }
                    Group {
                        ForEach(album.goals, id: \.self) { goal in
                            HStack {
                                Image(systemName: "square")
                                Text(goal)
                            }
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding(.leading, 25.0)
                        }
                    }.font(.headline)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 2)
                        .padding(.leading,45)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
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
            }.padding(.vertical, 135)
        }.onAppear {
            loadAlbumData()
        }
        
    }
    
    private func loadAlbumData() {
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                // Parse the album data from the snapshot's value
                if let json = value["json"] as? String, let imageURL = value["imageURL"] as? String {
                    // Process the JSON string and handle the album artwork URL to populate the album properties
                    album = generateViewWithCustomAlbum(jsonString: json, albumArtworkURL: imageURL)
                }
            }
        }
    }

    func generateViewWithCustomAlbum(jsonString: String, albumArtworkURL: String) -> Album {
        var album = Album(
            URL: "",
            title: "",
            caption: "",
            shortReflection: "",
            mindRecom: "",
            mindDescRecom: "",
            goals: [""]
        )

        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                
                // Extract values from JSON dictionary
                let title = json?["title"] as? String ?? ""
                let caption = json?["caption"] as? String ?? ""
                let shortReflection = json?["short-reflection"] as? String ?? ""
                let recommendation = json?["recommendation"] as? [String: Any]
                let mindfulness = recommendation?["mindfulness"] as? String ?? ""
                let shortDescription = recommendation?["short-description"] as? String ?? ""
                let goals = json?["goals"] as? [String] ?? [""]
                
                // Create the Album object
                album = Album(
                    URL: albumArtworkURL,
                    title: title,
                    caption: caption,
                    shortReflection: shortReflection,
                    mindRecom: mindfulness,
                    mindDescRecom: shortDescription,
                    goals: goals
                )
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return album
    }
    
    struct GeneratedView_Previews: PreviewProvider {
        static var previews: some View {
            let databaseRef = Database.database().reference()
            return GeneratedView(databaseRef: databaseRef)
        }
    }
    
}
