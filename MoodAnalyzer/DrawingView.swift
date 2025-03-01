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
    @State private var showResults = false
    @State private var aiAnalysis = "AI analyzing your drawings..."
    
    var body: some View {
        VStack {
            Text("Express Yourself Through Drawing")
                .font(.title)
                .padding()
            
            DrawingCanvas(canvasView: $canvasView)
                .frame(height: 400)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
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
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        let visionAPI = GroqVisionAPI()
        visionAPI.analyzeDrawing(image: image) { response in
            DispatchQueue.main.async {
                aiAnalysis = response ?? "Error analyzing drawing"
                showResults = true
            }
        }
    }
}

struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

#Preview {
    DrawingView()
}
