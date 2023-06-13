//
//  GeneratedView.swift
//  MUSAIC
//
//  Created by Suleman Dawood on 7/6/2023.
//

import SwiftUI
import Firebase
import UIKit

struct GeneratedView: View {
    
    let databaseRef: DatabaseReference
    
    let jsonString: String
    let albumArtworkURL: String
    
    @State private var isPlaying = false
    
    @State private var album: Album
    
    @Binding var selectedTab: Int
    
    init(databaseRef: DatabaseReference, selectedTab: Binding<Int>) {
        self.databaseRef = databaseRef
        self.jsonString = ""
        self.albumArtworkURL = ""
        
        _selectedTab = selectedTab
        
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
    
    @State private var isImageSaved = false
    
    var body: some View {
        ZStack(alignment: .center) {
            Image("Blur")
                .resizable()
                .frame(width: 450,height: 1000)
                .ignoresSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .center) {
                        AsyncImage(url: URL(string: album.URL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .padding(.bottom)
                                    .frame(width: 360, height: 360)
                            case .failure(let error):
                                Text("Failed to load image: \(error.localizedDescription)")
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }.padding(.top,50)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(album.title)
                                .font(.title)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 2.0)
                            Text(album.caption)
                                .font(.title2)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.leading)
                                .italic()
                                .padding(.bottom, 10.0)
                            HStack(spacing: 30) {
                                Button(action: {
                                    saveImageToGallery()
                                }) {
                                    Image("Upload")
                                        .resizable()
                                        .frame(width: 25, height: 35)
                                }
                                Button(action: {
                                        saveImageToGallery()
                                    }) {
                                        Text(isImageSaved ? "Image Saved" : "Save to gallery")
                                            .font(.headline)
                                            .foregroundColor(Color.white)
                                    }
                            }
                        }.padding(.leading, 20)
                    }
                }.padding(20.0)
                ZStack (alignment: .center){
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 1, green: 1, blue: 1))
                        .frame(width: 200, height: 40)
                        .opacity(0.3)
                    Button(action: {
                        selectedTab = 1
                    }) {
                        Text("Create New Album")
                            .foregroundColor(Color.white)
                            .foregroundColor(Color.white)
                    }
                }.padding(.bottom, 100)
            }.padding(.vertical, 100)
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
    
    private func saveImageToGallery() {
        guard let url = URL(string: album.URL) else {
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                DispatchQueue.main.async {
                    isImageSaved = true
                }
            }
        }
    }
}

struct GeneratedView_Previews: PreviewProvider {
    static var previews: some View {
        let databaseRef = Database.database().reference()
        return GeneratedView(databaseRef: databaseRef, selectedTab: Binding.constant(0))
    }
}
