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
        
        let enhancedPrompt = """
                Analyze this drawing from a psychological perspective using color theory and what the artwork is depicting(could be simple smiley or sad faces like emojis or objects like trees, flowers, hearts and simple objects), considering the following aspects:

                        1. What is the drawing depicting?
                        2. Formal elements: colors used, line quality, space utilization, composition, and overall style
                        3. Emotional content: mood and feelings expressed through the drawing
                        4. Symbolic meanings: potential meanings of specific elements and symbols
                        5. Psychological insights: what the drawing might suggest about the person's current emotional state
                        6. Strengths observed: positive aspects reflected in the artistic expression

                        Here are examples of different emotional expressions in drawings and how to interpret them:

                        Example 1: Happiness
                        Drawing description: Bright colors (yellow, orange, blue) with a smiling face, sunshine, and upward-oriented elements. Fluid, rounded lines and shapes. Open composition with elements spread across the page.
                        Analysis: The drawing conveys joy and optimism through bright colors and upward-facing elements. The bold, fluid strokes and open use of space suggest confidence and emotional freedom. The sunshine symbol reinforces themes of warmth and positivity. This expression indicates a present sense of emotional well-being and openness to experience.

                        Example 2: Sadness
                        Drawing description: Predominantly blue/gray colors, downward-facing lines, potentially a face with tears or downturned mouth. May include rain or clouds. Slower, heavier line pressure.
                        Analysis: The drawing expresses sadness through cooler color tones and downward-oriented elements. The heavier line pressure suggests emotional weight, while the limited color palette reflects a narrowed emotional focus. This pattern often indicates current feelings of disappointment or loss that the individual may be processing.

                        Example 3: Anger/Frustration
                        Drawing description: Sharp, jagged lines with heavy pressure. Often uses red or black prominently. May show crossed-out elements or scribbling. Spatial organization might be compressed or chaotic.
                        Analysis: The drawing conveys frustration through intense, angular strokes and bold colors. The heavy pressure and jagged quality suggest emotional intensity and potentially unexpressed feelings. The spatial compression might indicate feeling constrained or limited by circumstances, while the use of scribbling can represent a need to release pent-up energy.

                        Example 4: Neutral/Observational
                        Drawing description: Balanced composition with moderate line pressure. Often uses a variety of colors without strong dominance of any particular shade. May focus on depicting objects literally rather than expressively.
                        Analysis: The drawing shows a balanced emotional state through its measured composition and varied but controlled use of color. The observational quality suggests present-moment awareness and capacity for reflection. This typically indicates a state of emotional equilibrium and mindful engagement with one's surroundings.

                        Example 5: Anxiety
                        Drawing description: Repetitive elements, detailed patterns, or excessive shading. May show confinement through boxes or barriers. Often includes erratic line quality or numerous small elements.
                        Analysis: The drawing expresses anxiety through its repetitive patterns and detailed execution. The focus on control through detailed work may reflect attempts to manage internal uncertainty. The contained or compartmentalized spatial organization suggests a desire for structure when feeling emotionally unsettled.

                        Example 6: Mixed Joy and Sadness
                        Drawing description: Contrasting elements - perhaps sunshine and rain, or a smile with tears. May use both bright colors and cooler tones in different sections. Can include metaphorical elements like a rainbow after rain.
                        Analysis: The drawing reveals emotional complexity through its contrasting elements. This juxtaposition suggests the capacity to hold multiple emotions simultaneously and reflects emotional depth. The transitional symbols (like rainbows) may indicate resilience and the understanding that emotions are temporary and changeable.

                        Example 7: Excitement/Energy
                        Drawing description: Dynamic lines showing movement, spiral patterns, or starburst shapes. Typically uses vibrant colors with varied pressure. May fill the entire page with active elements.
                        Analysis: The drawing communicates high energy through its dynamic composition and vibrant color choices. The expansive use of space suggests enthusiasm and engagement. This expression often indicates a state of positive arousal and eagerness about current or anticipated experiences.

                        Example 8: Confusion/Uncertainty
                        Drawing description: Overlapping elements, unclear boundaries, or mixed symbolic content. May include question marks or multiple directional lines. Often shows erasure marks or corrections.
                        Analysis: The drawing reflects uncertainty through its ambiguous boundaries and overlapping elements. The correction marks suggest a process of working through thoughts rather than expressing a fixed conclusion. This pattern often indicates a period of transition or decision-making where multiple possibilities are being considered.

                        Example 9: Contentment/Peace
                        Drawing description: Balanced, harmonious composition with smooth, flowing lines. Often uses greens, blues, or pastels. May include nature elements like water, clouds, or trees in stable positions.
                        Analysis: The drawing conveys a sense of peace through its balanced composition and harmonious colors. The flowing quality suggests emotional ease, while nature elements reflect connection to something larger than oneself. This expression typically indicates a state of acceptance and present-moment satisfaction.

                        Example 10: Simple Stick Figures or Abstract Shapes
                        Drawing description: Basic representations using simple lines, circles, or geometric forms. May be minimalist with limited color or detail.
                        Analysis: Even in simple representations, emotional content can be detected through aspects like size relationships, positioning (centered vs. corner), line pressure, and spatial organization. The simplicity may indicate directness in emotional expression, focus on essential elements, or a preference for conceptual rather than detailed communication.

                        Please analyze the uploaded drawing with sensitivity to both obvious and subtle emotional expressions. Structure your analysis into the sections mentioned above, and provide a thoughtful interpretation focused on psychological well-being. Conclude with some encouraging observations.
                
                """
       

        // Construct JSON payload with the correct format for vision models
        let body: [String: Any] = [
            "model": "llama-3.2-11b-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": enhancedPrompt],
                        ["type": "image_url", "image_url": ["url": formattedImageDataURL]]
                    ]
                ]
            ],
            "temperature": 0.7,
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
