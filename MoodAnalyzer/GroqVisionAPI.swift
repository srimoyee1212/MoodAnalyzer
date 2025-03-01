import Foundation
import UIKit

struct GroqVisionAPI {
    let apiKey = "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" // Store securely, do not hardcode

    func analyzeDrawing(image: UIImage, completion: @escaping (String?) -> Void) {
        // Use the OpenAI-compatible endpoint instead of the direct Groq endpoint
        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Convert UIImage to Base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion("Error: Unable to process image")
            return
        }
        let base64String = imageData.base64EncodedString()
        let formattedImageDataURL = "data:image/jpeg;base64,\(base64String)"

        // Construct JSON payload with the correct format for vision models
        let body: [String: Any] = [
            "model": "llama-3.2-11b-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Analyze this drawing for psychological insights."],
                        ["type": "image_url", "image_url": ["url": formattedImageDataURL]]
                    ]
                ]
            ],
            "temperature": 1.0,
            "max_tokens": 1024,
            "top_p": 1.0,
            "stream": false
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion("Error: \(error.localizedDescription)")
            return
        }

        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Debug: print the raw JSON response as a string
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
            
            // Parse JSON response - using the same structure as your working example
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    completion("Error: Unable to find response content in API response structure")
                }
            } catch {
                completion("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}
