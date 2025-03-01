//
//  FinalReportView.swift
//  MoodAnalyzer
//
//  Created on 3/1/25.
//

import SwiftUI
import PDFKit

struct FinalReportView: View {
    let responses: [(question: Question, score: Int)]
    let drawingAnalysis: String
    let drawingImage: UIImage
    let isGreenMode: Bool
    
    @State private var assessmentNotes: String = ""
    @State private var showingPDFPreview = false
    @State private var showingShareSheet = false
    @State private var pdfDocument: PDFDocument?
    @State private var sharingItems: [Any] = []
    
    // Computed property to process category percentages
    var categoryPercentages: [String: Double] {
        var dict: [String: (sum: Int, count: Int)] = [:]
        for response in responses {
            let cat = response.question.category
            dict[cat, default: (0,0)].sum += response.score
            dict[cat, default: (0,0)].count += 1
        }
        var percentages: [String: Double] = [:]
        for (cat, data) in dict {
            let maxScore = data.count * 5
            percentages[cat] = (Double(data.sum) / Double(maxScore)) * 100.0
        }
        return percentages
    }
    
    // Process categories into groups
    var strengthCategories: [String] {
        return categoryPercentages.filter { $0.value >= 70.0 }.keys.sorted()
    }
    
    var neutralCategories: [String] {
        return categoryPercentages.filter { $0.value >= 40.0 && $0.value < 70.0 }.keys.sorted()
    }
    
    var concernCategories: [String] {
        return categoryPercentages.filter { $0.value < 40.0 }.keys.sorted()
    }
    
    // Overall emotional state assessment
    var overallAssessment: String {
        let averageScore = categoryPercentages.values.reduce(0.0, +) / Double(categoryPercentages.count)
        
        if averageScore >= 75.0 {
            return "The assessment indicates a generally positive emotional state. The individual demonstrates strong resilience and coping mechanisms with minimal indicators of psychological distress."
        } else if averageScore >= 60.0 {
            return "The assessment suggests a moderately stable emotional state. While showing adequate coping in several areas, there may be specific aspects that could benefit from supportive intervention."
        } else if averageScore >= 45.0 {
            return "The assessment reveals a mixed emotional state. The individual shows both strengths and potential concerns that warrant closer attention in a therapeutic context."
        } else {
            return "The assessment indicates potential emotional difficulties across multiple domains. A more thorough clinical evaluation is recommended to provide appropriate support and intervention strategies."
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section(header: Text("Assessment Information").font(.headline)) {
                        Text("Assessment Date: \(formattedDate())")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Assessment Type: \(isGreenMode ? "Child Assessment (Green Mode)" : "Adult Assessment (Standard Mode)")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Section(header: Text("Assessment Summary").font(.headline)) {
                        Text(overallAssessment)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemGray6))
                            )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Section(header: Text("Questionnaire Results").font(.headline)) {
                        ForEach(categoryPercentages.keys.sorted(), id: \.self) { category in
                            if let percentage = categoryPercentages[category] {
                                VStack(alignment: .leading) {
                                    Text("\(category): \(Int(percentage))%")
                                    GeometryReader { geometry in
                                        Rectangle()
                                            .fill(categoryColor(percentage))
                                            .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 20)
                                    }
                                    .frame(height: 20)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            if !strengthCategories.isEmpty {
                                Text("Areas of Strength:")
                                    .fontWeight(.semibold)
                                Text(strengthCategories.joined(separator: ", "))
                            }
                            
                            if !neutralCategories.isEmpty {
                                Text("Areas of Moderate Function:")
                                    .fontWeight(.semibold)
                                Text(neutralCategories.joined(separator: ", "))
                            }
                            
                            if !concernCategories.isEmpty {
                                Text("Areas of Potential Concern:")
                                    .fontWeight(.semibold)
                                Text(concernCategories.joined(separator: ", "))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray6))
                        )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Section(header: Text("Drawing Analysis").font(.headline)) {
                        Image(uiImage: drawingImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(10)
                            .padding(.vertical, 10)
                        
                        Text(drawingAnalysis)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemGray6))
                            )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Section(header: Text("Integrated Assessment").font(.headline)) {
                        Text(integratedAssessment())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemGray6))
                            )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    Section(header: Text("Additional Notes").font(.headline)) {
                        TextEditor(text: $assessmentNotes)
                            .frame(height: 150)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            generateAndViewPDF()
                        }) {
                            Text("Generate PDF Report")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            generateAndSharePDF()
                        }) {
                            Text("Share Report")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .padding(.vertical)
            }
            .navigationTitle("Therapeutic Assessment Report")
            .sheet(isPresented: $showingPDFPreview) {
                if let pdfDocument = pdfDocument {
                    PDFPreviewView(document: pdfDocument)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                SimpleShareSheet(items: sharingItems)
            }
        }
    }
    
    private func categoryColor(_ percentage: Double) -> Color {
        if percentage >= 70.0 {
            return Color.green
        } else if percentage >= 40.0 {
            return Color.orange
        } else {
            return Color.red
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
    
    private func integratedAssessment() -> String {
        // Integrating questionnaire and drawing analysis
        let avgScore = categoryPercentages.values.reduce(0.0, +) / Double(categoryPercentages.count)
        
        // Extract emotional tone from drawing analysis
        let drawingEmotionalTone = determineEmotionalTone(from: drawingAnalysis)
        
        // Create integrated assessment based on consistency between questionnaire and drawing
        let consistencyAssessment = assessConsistency(questionnaireScore: avgScore, drawingTone: drawingEmotionalTone)
        
        let assessmentMode = isGreenMode ? "child-appropriate" : "adult"
        
        return """
        This integrated assessment combines structured questionnaire responses with expressive drawing analysis to provide a more complete picture of the individual's emotional state.
        
        The questionnaire results (overall score: \(Int(avgScore))%) and the drawing analysis (emotional tone: \(drawingEmotionalTone)) \(consistencyAssessment)
        
        This assessment was conducted using the \(assessmentMode) assessment framework and should be interpreted within the appropriate developmental context.
        
        Note: This report is designed as a clinical aid and should be used in conjunction with professional clinical judgment and additional assessment methods as appropriate.
        """
    }
    
    private func determineEmotionalTone(from analysis: String) -> String {
        // This is a simplified approach - in a real app, you might use more sophisticated NLP
        let lowerAnalysis = analysis.lowercased()
        
        if lowerAnalysis.contains("happy") || lowerAnalysis.contains("joy") || lowerAnalysis.contains("positive") ||
           lowerAnalysis.contains("confident") || lowerAnalysis.contains("optimistic") {
            return "positive"
        } else if lowerAnalysis.contains("sad") || lowerAnalysis.contains("depress") || lowerAnalysis.contains("negative") ||
                  lowerAnalysis.contains("anxious") || lowerAnalysis.contains("stress") || lowerAnalysis.contains("worry") {
            return "negative"
        } else if lowerAnalysis.contains("mixed") || lowerAnalysis.contains("ambivalent") || lowerAnalysis.contains("complex") {
            return "mixed"
        } else {
            return "neutral"
        }
    }
    
    private func assessConsistency(questionnaireScore: Double, drawingTone: String) -> String {
        let questionnairePositive = questionnaireScore >= 65.0
        let questionnaireNegative = questionnaireScore < 40.0
        let questionnaireMixed = !questionnairePositive && !questionnaireNegative
        
        let drawingPositive = drawingTone == "positive"
        let drawingNegative = drawingTone == "negative"
        let drawingMixed = drawingTone == "mixed" || drawingTone == "neutral"
        
        if (questionnairePositive && drawingPositive) || (questionnaireNegative && drawingNegative) || (questionnaireMixed && drawingMixed) {
            return "show strong consistency, suggesting the assessment likely reflects the individual's authentic emotional state."
        } else if (questionnairePositive && drawingNegative) || (questionnaireNegative && drawingPositive) {
            return "show significant discrepancy, which may indicate complex emotional processing, potential response bias in the questionnaire, or unexpressed feelings that emerged in the drawing task."
        } else {
            return "show partial alignment with some inconsistencies, which is common when comparing structured and expressive assessment methods."
        }
    }
    
    // New simpler PDF generation and viewing
    private func generateAndViewPDF() {
        if let fileURL = generatePDFFile() {
            let pdfDoc = PDFDocument(url: fileURL)
            self.pdfDocument = pdfDoc
            showingPDFPreview = true
        }
    }
    
    // New sharing function that uses a simpler approach
    private func generateAndSharePDF() {
        if let fileURL = generatePDFFile() {
            sharingItems = [fileURL]
            showingShareSheet = true
        }
    }
    
    // Helper to generate the PDF file and return the URL
    private func generatePDFFile() -> URL? {
        return ShareController.generateAndSavePDF(
            responses: responses,
            categoryPercentages: categoryPercentages,
            drawingImage: drawingImage,
            drawingAnalysis: drawingAnalysis,
            integratedAssessment: integratedAssessment(),
            assessmentNotes: assessmentNotes,
            isGreenMode: isGreenMode
        )
    }
}

// PDF Preview View
struct PDFPreviewView: UIViewRepresentable {
    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

// For Preview
struct FinalReportView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleResponses: [(question: Question, score: Int)] = [
            (Question(text: "I handle difficult situations well.", category: "Resilience & Coping", isReverseScored: false), 4),
            (Question(text: "I get better tomorrow even after a tiring day.", category: "Resilience & Coping", isReverseScored: false), 3),
            (Question(text: "I feel lonely.", category: "Social Connection & Loneliness", isReverseScored: true), 2)
        ]
        
        let sampleAnalysis = """
        This drawing shows a balanced composition with strong use of color. The lines indicate confidence and emotional stability, while the spatial arrangement suggests openness to new experiences. The drawing style reflects a creative mindset with attention to detail.
        """
        
        return FinalReportView(
            responses: sampleResponses,
            drawingAnalysis: sampleAnalysis,
            drawingImage: UIImage(),
            isGreenMode: false
        )
    }
}
