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
    @State private var codeVerifier: String = ""
        @State private var codeChallenge: String = ""
        @State private var state: String = ""
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack{
                Image("Spotify")
                    .resizable()
                    .frame(width: 200, height: 200)
                
                Text("MUSAIC works best with Spotify")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text("We Find and play the best songs for you to find you next beat")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                Button(action: verifySpotify){
                    Text("LINK ACCOUNT")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                .padding()
                
                
                Button(action:{}) {
                    Text("I'll do it Later")
                        .foregroundColor(.white)
                        .underline()
                }
            }
        }
        
        .onOpenURL { incomingURL in
            print("App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
    }
    
    
    
    let spotify = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: "a5d89a0d332b46a1bd4fefe100f6c7b5"
        )
    )
    
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
    
    
    
    struct SpotifyVerify_Previews: PreviewProvider {
        static var previews: some View {
            SpotifyVerify()
        }
    }
}
