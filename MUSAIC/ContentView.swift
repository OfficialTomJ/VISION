//
//  ContentView.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 2/6/2023.
//

import SwiftUI

var thoughtsArray: [String] = []

struct ContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                GPT()
            }
        }
        .padding()
    }
}

func addThought() {
    var inputVal = "";
    thoughtsArray.append(inputVal)
}

func GPT() {
    generateGPT { (result) in
        switch result {
        case .success(let poem):
            print("Generated: \(poem)")
            // Update your UI or perform any other actions with the generated poem
        case .failure(let error):
            print("Error generating: \(error.localizedDescription)")
            // Handle the error gracefully
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
