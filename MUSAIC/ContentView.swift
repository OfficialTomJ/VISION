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
    
    @State private var summaryJSON = ""
    
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
                                .frame(width: calculateWidth(), height: 15)
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
                                    generateSummary()
                                }}
                        )
                        .accentColor(Color(hue: 1.0, saturation: 1.0, brightness: 1.0, opacity: 0))
                        .frame(width: 150)
                        Text("Slide to geneerate")
                            .font(.caption2)
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .opacity(0.8)
                    }
                    
                    .padding(0.0)
                    Text("...Or keep going")
                        .font(.caption)
                        .foregroundColor(Color.white)
                    
                    
                    
                    
                }.padding(.top, 50.0)
                

                
                
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: GeneratedView(jsonString: summaryJSON), isActive: $isNavigationActive) {
                    EmptyView()
                }
                .hidden()
            )
            
            
        }
        
        
        
    }
    
    
    func calculateWidth() -> CGFloat {
            let minWidth: CGFloat = 50
            let maxWidth: CGFloat = 300
            
            let progressValue = CGFloat(progressCounter)
            let progressRange = CGFloat(10)
            
            let width = minWidth + (maxWidth - minWidth) * (progressValue / progressRange)
            
            return min(max(width, minWidth), maxWidth)
        }
    
    func generateSummary() {
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
                            isNavigationActive = true
                        }
                    }
                } catch {
                    print("Error converting generated text to JSON: \(error)")
                }
            case .failure(let error):
                print("Error generating text: \(error)")
            }

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
