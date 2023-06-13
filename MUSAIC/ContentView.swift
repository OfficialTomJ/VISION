import SwiftUI
import Combine
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage

var prompts: [String] = [
    "What inspired you today?",
    "What little win did you experience?",
    "What unexpected discovery brought you joy today?",
    "What goal did you accomplish that made you proud?",
    "What piece of advice motivated you today?"
]

struct ContentView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var text: String = ""
    @State private var speed = 0.0
    @State private var prompt: String = "What Inspired you today?"
    @State private var thoughtsArray: [String] = []
    @State private var isToggled: Bool = false
    @State private var isNavigationActive = false
    
    @State private var spinnerVisible = 0.0
    
    @State private var isSummaryReady = false
    @State private var isImageReady = false
    
    @State private var summaryJSON = ""
    @State private var albumArtworkURL = ""
    
    @State private var errorAlertMessage: String = ""
    @State private var showErrorAlert: Bool = false
    
    @StateObject private var thoughtsArrayObserver = ThoughtsArrayObserver()
    
    @Binding var databaseRef: DatabaseReference
    
    var progressCounter: Int {
        thoughtsArray.count
    }
    
    init(databaseRef: Binding<DatabaseReference>) {
        let databaseRefGen = Binding.constant(Database.database().reference().child("albums").child(Auth.auth().currentUser!.uid ).childByAutoId())
            self._databaseRef = databaseRefGen
        }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top){
                Image("Background")
                    .resizable()
                    .ignoresSafeArea()
                VStack (alignment: .center)
                {
                    
                    
                    
                    HStack(){
                        Text(prompt)
                            .font(.title2)
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                        Button(action: {
                            shuffleThought(prompt: $prompt)
                        }) {
                            Image("Reload").resizable()
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
                    
                    HStack {
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 0.1, green: 0.5, blue: 0.7))
                            .frame(width: 20, height: 15)
                            .opacity(0.75)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.2, green: 0.5, blue: 0.7))
                                    .frame(width: 35, height: 18)
                                    .opacity(0.9)
                                    .overlay(Text("\(progressCounter)")
                                        .font(.caption)
                                        .foregroundColor(Color.white)
                                        .multilineTextAlignment(.leading)))
                            .padding(.horizontal, 8)
                        
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
                            Text("   Slide to generate")
                                .font(.caption2)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                                .opacity(0.9)
                        }
                    }
                    .padding(0.0)
                    Text("...Or keep going")
                        .font(.caption)
                        .foregroundColor(Color.white)
                }.padding(.top, 50.0)
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: GeneratedView(databaseRef: databaseRef), isActive: $isNavigationActive) {
                    EmptyView()
                }

                    .hidden()
            )
            .onAppear(perform: {
                            thoughtsArrayObserver.startObserving(userID: getCurrentUserID(), observedThoughtsArray: $thoughtsArray)
                        })
            .alert(isPresented: $showErrorAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(errorAlertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            
        }
        
    }
    
    func getCurrentUserID() -> String {
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        } else {
            return ""
        }
    }

    func generateSummaryAndImage() {
        spinnerVisible = 1.0
        var summaryPrompt = "You are a bot that only responds in JSON format. Based on these collected thoughts, "
        for thought in thoughtsArray {
            summaryPrompt += "`\(thought)`, "
        }
        summaryPrompt += "generate a summary in the theme of a music album with a title, caption, short personal reflection, 1 recommendation to do with mindfulness, and 2 goals for the week in this exact JSON format { \"title\": \"\", \"caption\": \"\", \"short-reflection\": \"\", \"recommendation\": { \"mindfulness\": \"\", \"short-description\": \"\" }, \"goals\": [ \"\", \"\" ] }"

        generateGPT(prompt: summaryPrompt) { result in
            switch result {
            case .success(let generatedText):
                do {
                    var cleanedText = generatedText.trimmingCharacters(in: .whitespacesAndNewlines)

                    if cleanedText.hasPrefix(".") {
                        let dotIndex = cleanedText.index(cleanedText.startIndex, offsetBy: 1)
                        cleanedText = String(cleanedText[dotIndex...])
                    }

                    cleanedText = cleanedText.replacingOccurrences(of: "`", with: "\"")
                    cleanedText = cleanedText.replacingOccurrences(of: ", }", with: " }")
                    cleanedText = cleanedText.replacingOccurrences(of: ", ]", with: " ]")
                    cleanedText = cleanedText.replacingOccurrences(of: ",\n}", with: "\n}")
                    cleanedText = cleanedText.replacingOccurrences(of: ",\n]", with: "\n]")

                    if let jsonData = cleanedText.data(using: .utf8),
                       let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        let jsonFormattedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        if let jsonFormattedString = String(data: jsonFormattedData, encoding: .utf8) {
                            self.summaryJSON = jsonFormattedString
                            self.isSummaryReady = true
                            self.checkNavigation()
                            self.generateImageIfNeeded()
                        }
                    }
                } catch {
                    print("Error converting generated text to JSON: \(error)")
                    // Show error
                    errorAlertMessage = "Something went wrong when generating the album. Add more thoughts or try again."
                    showErrorAlert = true
                }
            case .failure(let error):
                print("Error generating text: \(error)")
                errorAlertMessage = "Our AI generator is having some tech issues. Add more thoughts or try again."
                showErrorAlert = true
            }
        }
    }


    func generateImageIfNeeded() {
        guard isSummaryReady else {
            return
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
                            DispatchQueue.main.async {
                                self.albumArtworkURL = url.absoluteString // Update the albumArtworkURL
                                self.isImageReady = true
                                self.checkNavigation()
                            }
                        case .failure(let error):
                            // Handle the error
                            print("Image Error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("Error generating image: \(error)")
                errorAlertMessage = "Something went wrong when generating the album. Add more thoughts or try again."
                showErrorAlert = true
            }
        }
    }


    
    func checkNavigation() {
        if isNavigationActive {
            // Already navigating, no need to continue
            return
        }
        
        if isSummaryReady && isImageReady {
            isSummaryReady = false
            isImageReady = false
            
            spinnerVisible = 0.0
            
            // Check if already uploaded to Firebase
            let databaseRef = Database.database().reference().child("data")
            databaseRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    // Data already exists in Firebase, proceed with navigation
                    self.isNavigationActive = true
                } else {
                    // Upload JSON and image URL to Firebase
                    self.uploadDataToFirebase()
                }
            }
        }
    }

    func uploadDataToFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorAlertMessage = "User not authenticated"
            self.showErrorAlert = true
            return
        }
        
        // Download the image from the URL
        guard let url = URL(string: albumArtworkURL) else {
            self.errorAlertMessage = "Invalid URL"
            self.showErrorAlert = true
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                self.errorAlertMessage = error.localizedDescription
                self.showErrorAlert = true
                return
            }
            
            guard let imageData = data else {
                self.errorAlertMessage = "Failed to retrieve image data"
                self.showErrorAlert = true
                return
            }
            let metadata = StorageMetadata()
            metadata.contentType = "image/png" // Replace with the appropriate content type of your image

            // Upload the image data to Firebase storage
            let imageUUID = UUID().uuidString
            let storageRef = Storage.storage().reference().child("albumArtwork/\(uid)/\(imageUUID)")

            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    self.errorAlertMessage = error.localizedDescription
                    self.showErrorAlert = true
                    return
                }
                
                // Get the download URL of the uploaded image
                storageRef.downloadURL { url, error in
                    if let error = error {
                        self.errorAlertMessage = error.localizedDescription
                        self.showErrorAlert = true
                        return
                    }
                    
                    // Store the download URL in your data structure or use it as needed
                    if let downloadURL = url?.absoluteString {
                        let data = [
                            "json": self.summaryJSON,
                            "imageURL": downloadURL // Add the download URL to the data
                        ]
                        
                        self.databaseRef = Database.database().reference().child("albums").child(uid).childByAutoId()
                        databaseRef.setValue(data) { error, _ in
                            if let error = error {
                                self.errorAlertMessage = error.localizedDescription
                                self.showErrorAlert = true
                                return
                            }
                            
                            self.isNavigationActive = true
                        }
                    }
                }
            }
        }.resume()
    }



    
    func addThought() {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            
            let databaseRef = Database.database().reference()
            let userThoughtsRef = databaseRef.child(userID).child("thoughts")
            
            let newThoughtRef = userThoughtsRef.childByAutoId()
            newThoughtRef.setValue(text)
            
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
        
        let databaseRef = Binding.constant(Database.database().reference().child("albums").child(Auth.auth().currentUser!.uid ).childByAutoId())
        return ContentView(databaseRef: databaseRef)
    }
}


class ThoughtsArrayObserver: ObservableObject {
    private var databaseHandle: DatabaseHandle?
    private var isObserving = false
    
    deinit {
        stopObserving()
    }
    
    func startObserving(userID: String, observedThoughtsArray: Binding<[String]>) {
        guard !isObserving else {
            return
        }
        
        let databaseRef = Database.database().reference()
        let userThoughtsRef = databaseRef.child(userID).child("thoughts")
        
        // Observe for child added events
        databaseHandle = userThoughtsRef.observe(.childAdded, with: { [weak self] snapshot in
            if let thought = snapshot.value as? String {
                observedThoughtsArray.wrappedValue.append(thought)
            }
        })
        
        // Observe for child removed events
        userThoughtsRef.observe(.childRemoved, with: { [weak self] snapshot in
            if let thought = snapshot.value as? String, let index = observedThoughtsArray.wrappedValue.firstIndex(of: thought) {
                observedThoughtsArray.wrappedValue.remove(at: index)
            }
        })
        
        isObserving = true
    }
    
    func stopObserving() {
        if let databaseHandle = databaseHandle {
            let databaseRef = Database.database().reference()
            databaseRef.removeObserver(withHandle: databaseHandle)
        }
        
        isObserving = false
    }
}

