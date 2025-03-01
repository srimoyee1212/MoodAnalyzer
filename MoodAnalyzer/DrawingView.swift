//
//  DrawingView.swift
//  MoodAnalyzer
//
//  Updated version with Final Report integration
//

import SwiftUI
import PencilKit

struct DrawingView: View {
    let responses: [(question: Question, score: Int)]
    let isGreenMode: Bool
    
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: UIColor = .black
    @State private var isAnalyzing = false
    @State private var aiAnalysis = ""
    @State private var showAnalysisView = false
    @State private var showFinalReport = false
    @State private var currentDrawingImage: UIImage?
    
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
            
            Button(action: {
                isAnalyzing = true
                // Capture the drawing
                let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
                currentDrawingImage = image
                analyzeArtwork(image: image)
            }) {
                if isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Analyze Drawing")
                }
            }
            .padding()
            .frame(width: 200)
            .background(isAnalyzing ? Color.gray : Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(isAnalyzing)
            
            Button(action: {
                // Clear the canvas
                canvasView.drawing = PKDrawing()
            }) {
                Text("Clear Drawing")
                    .padding()
                    .frame(width: 200)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
            
            // Only show if we have analysis results
            if !aiAnalysis.isEmpty && currentDrawingImage != nil {
                Button(action: {
                    showFinalReport = true
                }) {
                    Text("Continue to Final Report")
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 16)
            }
        }
        .padding()
        .sheet(isPresented: $showAnalysisView) {
            AnalysisView(analysisText: aiAnalysis)
        }
        .fullScreenCover(isPresented: $showFinalReport) {
            if let drawingImage = currentDrawingImage {
                FinalReportView(
                    responses: responses,
                    drawingAnalysis: aiAnalysis,
                    drawingImage: drawingImage,
                    isGreenMode: isGreenMode
                )
            }
        }
    }
    
    private func analyzeArtwork(image: UIImage) {
        // Call the GroqVisionAPI
        GroqVisionAPI().analyzeDrawing(image: image) { response in
            DispatchQueue.main.async {
                isAnalyzing = false
                aiAnalysis = response ?? "Error analyzing drawing. Please try again."
                showAnalysisView = true
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
        let sampleResponses: [(question: Question, score: Int)] = []
        DrawingView(responses: sampleResponses, isGreenMode: false)
    }
}
