//
//  SignInView.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 9/6/2023.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var text: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("Background")
                .resizable()
                .frame(width: 450,height: 1000)
                .ignoresSafeArea(.all)
            VStack {
                Text("Welcome to MUSAIC")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.white)
                    .padding(.bottom, 1.0)
                Text("Where all things inspired")
                    .foregroundColor(Color.white)
                    .opacity(0.6)
                    .italic()
                TextField("Email", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding(.top, 100.0)
                    .frame(width: 300)
                    .opacity(0.6)
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                    .padding(.top, 5.0)
                    .frame(width: 300)
                    .opacity(0.6)
                ZStack (alignment: .center) {
                    Button(action: { signBtn(isSignUp: isSignUp) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 1, green: 1, blue: 1))
                                .frame(width: 200, height: 40)
                                .opacity(0.3)
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(.title3)
                                .foregroundColor(Color.white)
                        }
                    }
                }.padding(.top, 15)
                Toggle("Don't have an account? Sign up:", isOn: $isSignUp)
                    .foregroundColor(Color.white)
                    .padding([.top, .leading, .trailing], 50.0)
            }.padding(.top, 250)
        }
        .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel())
                }
    }
    
    func signBtn(isSignUp: Bool) {
        if isSignUp {
            // Sign up a new user
            Auth.auth().createUser(withEmail: text, password: password) { authResult, error in
                if let error = error {
                    showAlert = true
                    alertTitle = "Sign Up Error"
                    alertMessage = "\(error.localizedDescription)"
                    return
                }
                // User sign up successful
                print("Sign Up Successful")
            }
        } else {
            // Sign in an existing user
            Auth.auth().signIn(withEmail: text, password: password) { authResult, error in
                if let error = error {
                    showAlert = true
                    alertTitle = "Sign In Error"
                    alertMessage = "\(error.localizedDescription)"
                    return
                }
                // User sign in successful
                print("Sign In Successful")
            }
        }
    }
}


struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
