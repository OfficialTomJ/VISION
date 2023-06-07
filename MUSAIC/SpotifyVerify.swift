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
            .onOpenURL { incomingURL in
                                    print("App was opened via URL: \(incomingURL)")
                                    handleIncomingURL(incomingURL)
                                }
    }
    
}

let spotify = SpotifyAPI(
    authorizationManager: AuthorizationCodeFlowPKCEManager(
        clientId: "a5d89a0d332b46a1bd4fefe100f6c7b5"
    )
)
var codeVerifier: String = ""
var codeChallenge: String = ""
var state: String = ""

func verifySpotify() {
    generateCodeVerifierAndChallenge()
}
    
func generateCodeVerifierAndChallenge() {
    codeVerifier = String.randomURLSafe(length: 128)
    codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)
    state = String.randomURLSafe(length: 128)
    
    let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
        redirectURI: URL(string: "MUSAIC://spotify")!,
        codeChallenge: codeChallenge,
        state: state,
        scopes: [
            .playlistModifyPrivate,
            .userModifyPlaybackState,
            .playlistReadCollaborative,
            .userReadPlaybackPosition
        ]
    )!
    if let urlScheme = URL(string: authorizationURL.absoluteString) {
        UIApplication.shared.open(authorizationURL)
    }
}

private func handleIncomingURL(_ url: URL) {
    var cancellables = Set<AnyCancellable>()
    
    guard url.scheme == "spotify" else {
        // Request and access Spotify refresh tokens
        spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // Must match the code verifier that was used to generate the
            // code challenge when creating the authorization URL.
            codeVerifier: codeVerifier,
            // Must match the value used when creating the authorization URL.
            state: state
        )
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully authorized")
            case .failure(let error):
                if let authError = error as? SpotifyAuthorizationError, authError.accessWasDenied {
                    print("The user denied the authorization request")
                }
                else {
                    print("Couldn't authorize application: \(error)")
                }
            }
        })
        .store(in: &cancellables)
        
        print("Requesting access and refresh tokens...")
        return
    }

    }

func randomSong() {
    
}




struct SpotifyVerify_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyVerify()
    }
}
