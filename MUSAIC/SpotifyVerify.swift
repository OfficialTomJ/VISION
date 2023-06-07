//
//  SpotifyVerify.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 7/6/2023.
//

import SwiftUI
import SpotifyWebAPI
import Combine

struct SpotifyVerify: View {
    
    var body: some View {
        VStack {
            Button(action: verifySpotify) {
                Text("Verify Spotify")
            }
            Button(action: randomSong) {
                Text("Get Random Song")
            }
        }
    }
    
}

let spotify = SpotifyAPI(
    authorizationManager: ClientCredentialsFlowManager(
        clientId: "a5d89a0d332b46a1bd4fefe100f6c7b5", clientSecret: "5638f5c318d3451aa00bcd9cce9592ce"
    )
)

private var cancellables = Set<AnyCancellable>()

func verifySpotify() {
    spotify.authorizationManager.authorize()
        .sink(receiveCompletion: { completion in
            switch completion {
                case .finished:
                    print("successfully authorized application")
                case .failure(let error):
                    print("could not authorize application: \(error)")
            }
        })
        .store(in: &cancellables)
}


func randomSong() {
    spotify.search(query: "Pink Floyd", categories: [.track])
        .sink(
            receiveCompletion: { completion in
                print(completion)
            },
            receiveValue: { results in
                print(results)
            }
        )
        .store(in: &cancellables)
}




struct SpotifyVerify_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyVerify()
    }
}
