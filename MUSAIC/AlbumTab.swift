//
//  AlbumView.swift
//  MUSAIC
//
//  Created by Khushbu Oswal on 8/6/2023.
//

import SwiftUI
import Firebase
import FirebaseDatabase

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
    
    init(databaseRef: DatabaseReference) {
            self._databaseRef = State(initialValue: databaseRef)
        }
    
    @State private var selectedAlbumID: String? = nil {
            didSet {
                if let albumID = selectedAlbumID {
                    databaseRef = Database.database().reference().child("albums").child(Auth.auth().currentUser!.uid ).child(albumID)
                    print(databaseRef)
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
                    
                    print("First album item:")
                    print(albumItems)
                    
                    
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




    var body: some View {
        NavigationView {
        ZStack(alignment: .top){
            Image("Background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                if let selectedAlbum = albumItems.first(where: { $0.id == selectedAlbumID }) {
                    let imageURL = selectedAlbum.imageURL
                    let title = selectedAlbum.title as? String ?? ""
                    
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            Image("sample")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding(.top, 40.0)
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding(.top, 40.0)
                        case .failure:
                            Image("sample")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding(.top, 40.0)
                        @unknown default:
                            Image("sample")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .padding(.top, 40.0)
                        }
                    }
                    
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Image("")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding(.top, 40.0)
                    
                    Text("No albums available")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                
                HStack {
                    Button(action: {
                        isNavigationActive = true
                    }) {
                        Text("Play")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 10.0)
                    }
                    
                    Button(action: {
                        isNavigationActive = true
                        print("Database Ref")
                        print(databaseRef)
                    }){
                        Image("Play")
                            .resizable()
                            .frame(width: 50, height: 50)
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
                        ForEach(albumItems) { albumItem in
                            let albumID = albumItem.id
                            let imageURL = albumItem.imageURL
                            let albumData = albumItem.data
                            
                            if let url = URL(string: imageURL) {
                                Button(action: {
                                    selectedAlbumID = albumID
                                }) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            Image("")
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                        case .failure:
                                            Image("sample")
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                        @unknown default:
                                            Image("sample")
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                        }
                                    }
                                }
                            } else {
                                Image("sample")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                            }
                        }
                        
                    }
                }
            }
            .onAppear {
                fetchAlbums()
            }
        }
        .background(
            NavigationLink(destination: GeneratedView(databaseRef: databaseRef), isActive: $isNavigationActive) {
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
        return AlbumTab(databaseRef: databaseRef)
    }
}
