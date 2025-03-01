//
//  DrawingView.swift
//  MoodAnalyzer
//
//  Created by Srimoyee Mukhopadhyay on 2/28/25.
//
import SwiftUI
import PencilKit

struct DrawingView: View {
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: UIColor = .black
    @State private var showResults = false
    @State private var aiAnalysis = "AI analyzing your drawings..."
    
    // Define a palette of colors for the user to choose from.
    let palette: [UIColor] = [.black, .red, .green, .blue, .orange, .purple]
    
    var body: some View {
        VStack {
            Text("Express Yourself Through Drawing")
                .font(.title)
                .padding()
            
            DrawingCanvas(canvasView: $canvasView, selectedColor: selectedColor)
                .frame(height: 400)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding()
            
            // Color palette selector
            HStack {
                ForEach(palette, id: \.self) { color in
                    Circle()
                        .fill(Color(color))
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            selectedColor = color
                        }
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.gray : Color.clear, lineWidth: 2)
                        )
                }
            }
            .padding()
            
            Button("Analyze Drawing") {
                analyzeArtwork()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if showResults {
                Text(aiAnalysis)
                    .padding()
            }
        }
        .padding()
    }
    
    private func analyzeArtwork() {
        // Capture the current drawing as an image
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        // Call the GroqVisionAPI (from your GroqVisionAPI.swift file)
        GroqVisionAPI().analyzeDrawing(image: image) { response in
            DispatchQueue.main.async {
                aiAnalysis = response ?? "Error analyzing drawing"
                showResults = true
            }
        }
    }
}

struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var selectedColor: UIColor
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: selectedColor, width: 5)
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update the inking tool when the selected color changes.
        uiView.tool = PKInkingTool(.pen, color: selectedColor, width: 5)
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView()
    }
}
