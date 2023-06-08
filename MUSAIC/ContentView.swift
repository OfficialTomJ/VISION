import SwiftUI
import Combine

var prompts: [String] = [
    "What inspired you today?",
    "What little win did you experience?",
    "What unexpected discovery brought you joy today?",
    "What goal did you accomplish that made you proud?",
    "What piece of advice motivated you today?"
]

struct ContentView: View {

    @State private var text: String = ""
    @State private var speed = 0.0
    @State private var prompt: String = "What Inspired you today?"
    @State private var thoughtsArray: [String] = []
    @State private var isToggled: Bool = false
    @State private var isNavigationActive = false
    
    @State private var isSummaryReady = false
    @State private var isImageReady = false
    
    @State private var summaryJSON = ""
    @State private var albumArtworkURL = ""
    
    var progressCounter: Int {
        thoughtsArray.count
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top){
                Image("Background")
                    .resizable()
                    .ignoresSafeArea()
                VStack (alignment: .center)
                {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.1, green: 0.5, blue: 0.7))
                        .frame(width: 300, height: 15)
                        .opacity(0.5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.2, green: 0.5, blue: 0.7))
                                .frame(width: 50, height: 15)
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
                            Image("regen").resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 20,height: 20)
                        }
                        
                    }.padding(.top, 240.0)
                    HStack {
                        TextField("Enter thoughts", text: $text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .frame(width: 330)
                            .opacity(0.5)
                        Button(action: {
                            addThought()
                        }) {
                            Image("Send").resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 25,height: 25)
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .frame(width: 150, height: 20)
                            .opacity(0.6)
                        
                        Slider(
                            value: $speed,
                            in: 0...100,
                            onEditingChanged: { editingChanged in
                                if speed == 100 && !editingChanged {
                                    generateSummaryAndImage()
                                }}
                        )
                        .disabled(thoughtsArray.count <= 4)
                        .accentColor(Color(hue: 1.0, saturation: 1.0, brightness: 1.0, opacity: 0))
                        .frame(width: 150)
                        
                    }
                    .padding()
                    Text("Slide to generate")
                        .opacity(thoughtsArray.count <= 4 ? 0.5 : 1)
                        .font(.title3)
                        .foregroundColor(Color.white)
                    Text("Or keep going")
                        .opacity(thoughtsArray.count <= 4 ? 0 : 1)
                        .font(.caption)
                        .foregroundColor(Color.white)
                    
                }.padding(.top, 50.0)
                
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: GeneratedView(jsonString: summaryJSON, albumArtworkURL: albumArtworkURL), isActive: $isNavigationActive) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
    
    func generateSummaryAndImage() {
        var summaryPrompt = "You are a bot that only responds in JSON format. Based on these collected thoughts, "
        for thought in thoughtsArray {
            summaryPrompt += "`\(thought)`, "
        }
        summaryPrompt += "generate a summary in the theme of a music album with a title, caption, short personal reflection, 1 recommendation to do with mindfulness, and 2 goals for the week in this JSON format { \"title\": \"\", \"caption\": \"\", \"short-reflection\": \"\", \"recommendation\": { \"mindfulness\": \"\", \"short-description\": \"\" }, \"goals\": [ \"\", \"\" ] }"

        generateGPT(prompt: summaryPrompt) { result in
            switch result {
            case .success(let generatedText):
                do {
                    if let jsonData = generatedText.data(using: .utf8),
                       let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        let jsonFormattedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        if let jsonFormattedString = String(data: jsonFormattedData, encoding: .utf8) {
                            summaryJSON = jsonFormattedString
                            print("Summary JSON:")
                            print(summaryJSON)
                            isSummaryReady = true
                            checkNavigation()
                        }
                    }
                } catch {
                    print("Error converting generated text to JSON: \(error)")
                }
            case .failure(let error):
                print("Error generating text: \(error)")
            }
        }
        
        var imgPrompt = "Based on these collected thoughts, "
        for thought in thoughtsArray {
            imgPrompt += "`\(thought)`, "
        }
        imgPrompt += "Describe an album cover artwork in 1 sentence."
        
        // Generate DALLE Image
        generateGPT(prompt: imgPrompt) { result in
            switch result {
            case .success(let generatedText):
                do {
                    DALLEGenerate(prompt: String(generatedText)) { result in
                        switch result {
                        case .success(let url):
                            // Handle the generated image URL
                            print("Generated image URL: \(url.absoluteString)")
                            albumArtworkURL = url.absoluteString
                            isImageReady = true
                            checkNavigation()
                        case .failure(let error):
                            // Handle the error
                            print("Image Error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("Error generating text: \(error)")
            }
        }
    }
    
    func checkNavigation() {
        if isSummaryReady && isImageReady {
            isNavigationActive = true
        }
    }
    
    func addThought() {
        if !text.isEmpty {
            thoughtsArray.append(text)
            print(thoughtsArray)
            text = ""
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
