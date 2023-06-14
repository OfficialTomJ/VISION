//
//  SignInView.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 9/6/2023.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isSignUp: Bool
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var signInAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Image("Background")
                .resizable()
                .frame(width: 450, height: 1000)
                .ignoresSafeArea(.all)
            VStack {
                Text("Welcome to VISION")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.white)
                    .padding(.bottom, 1.0)
                Text("Generate Inspiration")
                    .foregroundColor(Color.white)
                    .opacity(0.6)
                    .italic()
                TextField("Email", text: $email)
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
                ZStack(alignment: .center) {
                    Button(action: { signInAction() }) {
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
}
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(email: .constant(""), password: .constant(""), isSignUp: .constant(false), signInAction: {})
    }
}
