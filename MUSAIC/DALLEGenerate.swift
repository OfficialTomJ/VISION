//
//  DALLEGenerate.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 8/6/2023.
//

import Foundation

func DALLEGenerate(prompt: String, completion: @escaping (Result<URL, Error>) -> Void) {
    // Set the DALL·E 2 API endpoint URL
    let apiUrl = URL(string: "https://api.openai.com/v1/images/generations")!

    // Set your OpenAI API key
    guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
          let config = NSDictionary(contentsOfFile: configPath),
          let apiKey = config["GPT"] as? String else {
        fatalError("Failed to load GPT API key from Config.plist")
    }

    // Set the headers with the API key
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

    // Set the request body
    let parameters: [String: Any] = [
        "prompt": prompt,
        "size": "512x512",
    ]
    let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

    request.httpBody = jsonData

    // Make a POST request to the DALL·E 2 API
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "API Error", code: 0, userInfo: nil)))
            return
        }

        do {
            // Parse the API response to obtain the image link
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let dataArray = json?["data"] as? [[String: Any]], let firstData = dataArray.first, let imageLink = firstData["url"] as? String, let url = URL(string: imageLink) {
                completion(.success(url))
            } else {
                completion(.failure(NSError(domain: "URL Error", code: 0, userInfo: nil)))
            }
        } catch {
            completion(.failure(error))
        }

    }

    task.resume()
}
