import Foundation
import UIKit

struct GroqVisionAPI {
    let apiKey = "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" // Store securely, do not hardcode

    func analyzeDrawing(image: UIImage, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.groq.com/v1/chat/completions")!
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

        // Construct JSON payload
        let body: [String: Any] = [
            "model": "llama-3.2-11b-vision-preview",
            "messages": [["role": "user", "content": "Analyze this drawing for psychological insights."]],
            "image": base64String,
            "temperature": 1,
            "max_completion_tokens": 1024,
            "top_p": 1,
            "stream": false
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // Send request
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Parse JSON response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content)
            } else {
                completion("Error: Unable to parse AI response")
            }
        }.resume()
    }
}
