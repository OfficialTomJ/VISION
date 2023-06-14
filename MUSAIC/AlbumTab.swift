//
//  AlbumView.swift
//  MUSAIC
//
//  Created by Khushbu Oswal on 8/6/2023.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import Kingfisher
import ColorThiefSwift

struct AlbumItem: Identifiable {
    let id: String
    var imageURL: String
    var title: String
    var data: [String: Any]
}

struct AlbumTab: View {
    @State private var offset = CGSize.zero
    
    @State private var albums: [String: Any] = [:]
    @State private var albumItems: [AlbumItem] = []
    
    @State private var databaseRef: DatabaseReference
    
    @State private var gradientColors: [Color] = []
    
    @Binding var selectedTab: Int
    
    init(databaseRef: DatabaseReference, selectedTab: Binding<Int>) {
        self._databaseRef = State(initialValue: databaseRef)
        _selectedTab = selectedTab
    }
    
    @State private var selectedAlbumID: String? = nil {
        didSet {
            if let albumID = selectedAlbumID {
                databaseRef = Database.database().reference().child("albums").child(Auth.auth().currentUser!.uid).child(albumID)
            }
        }
    }
    
    @State private var isNavigationActive = false
    
    func fetchAlbums() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User ID is nil")
            return
        }
        
        let ref = Database.database().reference().child("albums").child(uid)
        
        ref.observe(.value) { snapshot in
            if snapshot.childrenCount > 0 {
                if let data = snapshot.value as? [String: Any] {
                    albums = data
                    albumItems = data.compactMap { key, value in
                        guard let albumData = value as? [String: Any],
                              let imageURL = albumData["imageURL"] as? String,
                              let jsonString = albumData["json"] as? String,
                              let jsonData = jsonString.data(using: .utf8),
                              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                              let title = json["title"] as? String else {
                            return nil
                        }
                        
                        return AlbumItem(id: key, imageURL: imageURL, title: title, data: albumData)
                    }
                    
                    if albumItems.isEmpty {
                        selectedAlbumID = nil
                    } else if selectedAlbumID == nil || !albumItems.contains(where: { $0.id == selectedAlbumID }) {
                        selectedAlbumID = albumItems.first?.id
                    }
                    
                    generateGradientColors()
                    
                    if let urlString = albumItems.first?.imageURL {
                        // ... existing code ...
                    } else {
                        print("No album items")
                    }
                } else {
                    print("Snapshot data is nil")
                }
            } else {
                print("Snapshot does not exist")
            }
        }
    }
    
    private func generateGradientColors() {
        guard let selectedAlbum = albumItems.first(where: { $0.id == selectedAlbumID }),
              let imageURL = URL(string: selectedAlbum.imageURL) else {
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
            switch result {
            case .success(let value):
                let image = value.image
                if let palette = ColorThief.getPalette(from: image, colorCount: 2) {
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
            case .failure(let error):
                print("Image retrieval failed: \(error)")
            }
        }
    }



    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Image("Background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    if let selectedAlbum = albumItems.first(where: { $0.id == selectedAlbumID }) {
                        let imageURL = selectedAlbum.imageURL
                        let title = selectedAlbum.title as? String ?? ""
                        
                        KFImage(URL(string: imageURL))
                            .resizable()
                            .frame(width: 200, height: 200)
                            .padding(.top, 30.0)
                            .shadow(color: .white.opacity(0.4), radius: 10)
                        
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(10)
                    } else {
                        Image("")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .padding(.top, 30.0)
                        
                        Text("No albums available")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    
                        Button(action: {
                            isNavigationActive = true
                        }) {
                            HStack(alignment: .center, spacing: 20) {
                                Text("View")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Image("Play")
                                    .resizable()
                                .frame(width: 50, height: 50)
                            }.padding(.vertical, 10)
                                .padding(.horizontal,12)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(60)
                        }.padding(.bottom, 30)
                    VStack(spacing: 0){
                        Rectangle().fill(Color.white.opacity(0.0)).frame(height: 20)
                            
                            
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVGrid(columns: gridItems(), spacing: 20) {
                                ForEach(albumItems) { albumItem in
                                    let albumID = albumItem.id
                                    let imageURL = albumItem.imageURL
                                    let albumData = albumItem.data
                                    
                                    if let url = URL(string: imageURL) {
                                        Button(action: {
                                            selectedAlbumID = albumID
                                            generateGradientColors()
                                        }) {
                                            KFImage(url)
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                        }
                                    } else {
                                        Image("sample")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                    }
                                }
                            }
                        }.padding(24)
                            .background(Color.white.opacity(0.3))
                    }
                    
                }
                .onAppear {
                    fetchAlbums()
                }
            }
            .background(
                NavigationLink(destination: GeneratedView(databaseRef: databaseRef, selectedTab: $selectedTab, gradientColors: gradientColors), isActive: $isNavigationActive) {
                    EmptyView()
                }
                .hidden()
            )
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
        let databaseRef = Database.database().reference().child("albums").child(Auth.auth().currentUser!.uid)
        return AlbumTab(databaseRef: databaseRef, selectedTab: Binding.constant(0))
    }
}

