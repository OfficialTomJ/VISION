//
//  SummaryModel.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 7/6/2023.
//

import Foundation

struct Album: Decodable {
    let title: String
    let caption: String
    let shortReflection: String
    let mindRecom: String
    let mindDescRecom: String
    let goals: [String]
}

func loadAlbum() {
    // Simulate loading JSON data from a network request
    let json = """
        {
            "title": "Vibrant Transitions",
            "caption": "Embrace the Colors of Life",
            "shortReflection": "Vibrant Transitions is a musical journey...",
            "mindRecom": "Mindful Mornings",
            "mindDescRecom": "Start your day with mindfulness exercises...",
            "goals": [
                "Practice guitar solos for the Friday band rehearsal.",
                "Initiate a conversation with another classmate to expand social connections."
            ]
        }
        """
    
    // Convert the JSON string to Data
    guard let jsonData = json.data(using: .utf8) else {
        print("Invalid JSON data")
        return
    }
    
    do {
        // Decode the JSON data into an instance of Album
        let album = try JSONDecoder().decode(Album.self, from: jsonData)
        
        // Access the properties of the album
        print(album.title)
        print(album.caption)
        print(album.shortReflection)
        print(album.mindRecom)
        print(album.mindDescRecom)
        print(album.goals)
    } catch {
        print("Failed to decode album: \(error)")
    }
}
