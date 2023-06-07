//
//  SpotifyVerify.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 7/6/2023.
//

import SwiftUI
import SpotifyWebAPI

struct SpotifyVerify: View {
    var body: some View {
        Button(action: verifySpotify) {
            Text("Verify Spotify")
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
    guard url.scheme == "spotify" else {
        //Request and access Spotify refresh tokens
        return
        }
    }



struct SpotifyVerify_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyVerify()
    }
}