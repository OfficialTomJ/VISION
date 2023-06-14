//
//  GeneratedView.swift
//  MUSAIC
//
//  Created by Suleman Dawood on 7/6/2023.
//

import SwiftUI
import Firebase
import Kingfisher
import ColorThiefSwift

struct GeneratedView: View {
    
    let databaseRef: DatabaseReference
    let jsonString: String
    let albumArtworkURL: String
    
    @State private var isPlaying = false
    
    @State private var album: Album
    
    @Binding var selectedTab: Int
    
    @State private var gradientColors: [Color] = []
    
    init(databaseRef: DatabaseReference, selectedTab: Binding<Int>, gradientColors: [Color]) {
        self.databaseRef = databaseRef
        self.jsonString = ""
        self.albumArtworkURL = ""
        
        _selectedTab = selectedTab
        self.gradientColors = gradientColors
        
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
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.all)
            ScrollView {
                VStack(alignment: .center) {
                    VStack(alignment: .center) {
                        if let url = URL(string: album.URL) {
                            KFImage(url)
                                .resizable()
                                .padding(.bottom)
                                .frame(width: 340, height: 340)
                                .shadow(color: .white.opacity(0.4), radius: 5)
                        } else {
                            Text("Invalid image URL")
                        }
                    }.padding(.top, 20)
                    
                    ZStack {
                        
                        VStack(alignment: .leading) {
                            Text(album.title)
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.bottom, 2.0)
                            Text(album.caption)
                                .font(.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .italic()
                                .padding(.bottom, 10.0)
                            HStack(spacing: 20) {
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
                                        .foregroundColor(.white)
                                }
                            }
                        }.padding(20)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .frame(width: 360)
                    }
                }.padding(0)
                ZStack (alignment: .center){
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 1, green: 1, blue: 1))
                        .frame(width: 200, height: 40)
                        .opacity(0.3)
                    Button(action: {
                        selectedTab = 1
                    }) {
                        Text("Create New Album")
                            .foregroundColor(.white)
                            .foregroundColor(.white)
                    }
                }.padding(.bottom, 100)
                    .padding(.top,20)
            }.ignoresSafeArea(.all)
                .padding(.vertical,10)
                

        }.onAppear {
            loadAlbumData()
        }
    }
    
    private func generateGradientColors() {
        print("Album URL:")
        print(album.URL)
        guard let imageURL = URL(string: album.URL) else {
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { [self] data, response, error in
            guard let data = data, let uiImage = UIImage(data: data), error == nil else {
                // Handle the error or empty response if any
                return
            }
            
            DispatchQueue.global().async {
                if let palette = ColorThief.getPalette(from: uiImage, colorCount: 2) {
                    guard palette.count >= 2 else {
                        return
                    }
                    
                    let dominantColor1 = palette[0]
                    let dominantColor2 = palette[1]
                    
                    let red1 = Double(dominantColor1.r) / 255.0
                    let green1 = Double(dominantColor1.g) / 255.0
                    let blue1 = Double(dominantColor1.b) / 255.0
                    let uiColor1 = UIColor(red: CGFloat(red1), green: CGFloat(green1), blue: CGFloat(blue1), alpha: 1.0)
                    let gradientColor1 = Color(uiColor1)
                    
                    let red2 = Double(dominantColor2.r) / 255.0
                    let green2 = Double(dominantColor2.g) / 255.0
                    let blue2 = Double(dominantColor2.b) / 255.0
                    let uiColor2 = UIColor(red: CGFloat(red2), green: CGFloat(green2), blue: CGFloat(blue2), alpha: 1.0)
                    let gradientColor2 = Color(uiColor2)
                    
                    DispatchQueue.main.async {
                        self.gradientColors = [gradientColor1, gradientColor2]
                    }
                }
            }
        }.resume()
    }


    
    private func loadAlbumData() {
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                // Parse the album data from the snapshot's value
                if let json = value["json"] as? String, let imageURL = value["imageURL"] as? String {
                    // Process the JSON string and handle the album artwork URL to populate the album properties
                    album = generateViewWithCustomAlbum(jsonString: json, albumArtworkURL: imageURL)
                    generateGradientColors()
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
        let gradientColors: [Color] = []
        return GeneratedView(databaseRef: databaseRef, selectedTab: Binding.constant(0), gradientColors: gradientColors)
    }
}
