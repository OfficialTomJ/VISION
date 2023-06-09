//
//  SignInView.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 9/6/2023.
//

import SwiftUI

struct SignInView: View {
    @State private var text: String = ""
    @State private var password: String = ""
    
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
                ZStack (alignment: .center){
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 1, green: 1, blue: 1))
                        .frame(width: 200, height: 40)
                        .opacity(0.3)
                    Button(action: {}) {
                        Text("Sign Up")
                            .font(.title3)
                            .foregroundColor(Color.white)
                    }
                }.padding(.top, 15)
            }.padding(.top, 250)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
