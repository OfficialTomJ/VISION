//
//  ContentView.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 2/6/2023.
//

import SwiftUI

var prompts: [String] = [
    "What inspired you today?",
    "What little win did you experience?",
    "Prompt 3",
    "Prompt 4",
    "Prompt 5"
]

struct ContentView: View {

    @State private var text: String = ""
    @State private var prompt: String = "What Inspired you today?"
    @State private var thoughtsArray: [String] = []
    var progressCounter: Int {
            thoughtsArray.count
        }
    
    var body: some View {
        ZStack(alignment: .top){
            Image("Background")
                .resizable()
                .ignoresSafeArea()
            VStack (alignment: .center)
            {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.4, green: 0.6, blue: 0.9))
                    .frame(width: 300, height: 15)
                    .opacity(0.8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.5, green: 0.7, blue: 0.9))
                            .frame(width: 100, height: 15)
                            .opacity(0.9)
                            .overlay(Text("\(progressCounter)")
                                .font(.caption)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.leading)))
                HStack(){
                    Text(prompt)
                        .font(.title2)
                        .foregroundColor(Color.white)
                    Button(action: {
                        shuffleThought(prompt: $prompt)
                    }) {
                        Image("Reload")
                    }

                }.padding(.top, 300.0)
                HStack {
                    TextField("Enter thoughts", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .frame(width: 330)
                        .opacity(0.5)
                    Button(action: {
                        addThought()
                    }) {
                        Image("Send")
                    }
                }
            }.padding(.top, 50.0)
        }
    }
    
    func addThought() {
        if (!text.isEmpty) {
            thoughtsArray.append(text)
        }
    }
    
    func shuffleThought(prompt: Binding<String>) {
        var newPrompt = prompt.wrappedValue
        while newPrompt == prompt.wrappedValue {
            prompts.shuffle()
            newPrompt = prompts.first ?? ""
        }
        prompt.wrappedValue = newPrompt
    }
}

func GPT() {
    generateGPT(prompt: "Tell me a funny joke!") { (result) in
        switch result {
        case .success(let text):
            print("Generated: \(text)")
        case .failure(let error):
            print("Error generating: \(error.localizedDescription)")
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
        
}
