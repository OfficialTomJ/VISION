//
//  GPTGenerate.swift
//  MUSAIC
//
//  Created by Thomas Johnston on 6/6/2023.
//

import Foundation

func generateGPT(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
    guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
          let config = NSDictionary(contentsOfFile: configPath),
          let apiKey = config["GPT"] as? String else {
        fatalError("Failed to load GPT API key from Config.plist")
    }
    
    let endpoint = "https://api.openai.com/v1/engines/text-davinci-002/completions"
    let parameters: [String: Any] = [
        "prompt": prompt,
        "max_tokens": 500
    ]

    guard let url = URL(string: endpoint) else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        let requestData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = requestData
    } catch {
        completion(.failure(error))
        return
    }

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
            return
        }

        do {
            let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])

            if let responseObject = responseJSON as? [String: Any],
               let choices = responseObject["choices"] as? [[String: Any]],
               let text = choices.first?["text"] as? String {
                   completion(.success(text))
            } else {
                completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
            }
        } catch {
            completion(.failure(error))
        }
    }


    task.resume()
}
