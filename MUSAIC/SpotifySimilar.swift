//
//  SpotifySimilar.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 6/6/2023.
//

import Foundation

func findSimilarSongs(theme: String) {
    let baseURL = "https://api.spotify.com/v1"
    let searchEndpoint = "/search"
    let query = "q=\(theme)&type=track"

    // Your Spotify API access token
    let accessToken = "YOUR_ACCESS_TOKEN"

    // Construct the URL
    let urlString = baseURL + searchEndpoint + "?" + query
    guard let url = URL(string: urlString) else {
        print("Invalid URL: \(urlString)")
        return
    }

    // Create the URL request
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    // Send the request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error: \(error)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid HTTP response")
            return
        }

        if httpResponse.statusCode == 200, let data = data {
            do {
                // Parse the JSON response
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let tracks = json?["tracks"] as? [String: Any], let items = tracks["items"] as? [[String: Any]] {
                    for item in items {
                        if let name = item["name"] as? String, let artists = item["artists"] as? [[String: Any]], let artistName = artists.first?["name"] as? String {
                            print("Song: \(name)")
                            print("Artist: \(artistName)")
                            print("------------------")
                        }
                    }
                }
            } catch {
                print("Error parsing JSON response: \(error)")
            }
        } else {
            print("HTTP status code: \(httpResponse.statusCode)")
        }
    }

    task.resume()
}

