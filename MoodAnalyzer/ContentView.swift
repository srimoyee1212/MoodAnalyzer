import SwiftUI

// Define the Question struct.
struct Question: Identifiable {
    let id = UUID()
    let text: String
    let category: String
    let isReverseScored: Bool
}

enum AppMode: String, CaseIterable, Identifiable {
    case regular = "Regular Mode"
    case green = "Green Mode"
    case drawingOnly = "Drawing Only Mode"
    
    var id: String { self.rawValue }
}

// The main ContentView shows a NavigationView with the ModeSelectionView.
struct ContentView: View {
    var body: some View {
        NavigationView {
            ModeSelectionView()
        }
    }
}

// ModeSelectionView allows the user to choose a mode and then press Continue.
struct ModeSelectionView: View {
    @State private var selectedMode: AppMode = .regular  // default mode
    @State private var navigateToMain = false
    @State private var navigateToDrawingOnly = false
    
    var body: some View {
        VStack {
            Text("Choose Your Mode")
                .font(.title)
                .padding()
            
            Picker("Select Mode", selection: $selectedMode) {
                ForEach(AppMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Description of selected mode
            VStack(alignment: .leading, spacing: 10) {
                Text(getModeDescription())
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemGray6))
                    )
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            Button(action: {
                // When the user taps Continue, trigger navigation based on mode.
                if selectedMode == .drawingOnly {
                    navigateToDrawingOnly = true
                } else {
                    navigateToMain = true
                }
                print("Mode selected: \(selectedMode.rawValue)")
            }) {
                Text("Continue")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Multiple NavigationLinks for different destinations
            NavigationLink(
                destination: MainQuestionsView(isGreenMode: selectedMode == .green),
                isActive: $navigateToMain,
                label: { EmptyView() }
            )
            
            NavigationLink(
                destination: DrawingOnlyView(),
                isActive: $navigateToDrawingOnly,
                label: { EmptyView() }
            )
        }
        .padding()
    }
    
    private func getModeDescription() -> String {
        switch selectedMode {
        case .regular:
            return "Adult assessment with personalized questions and drawing analysis. Comprehensive emotional evaluation with detailed metrics."
        case .green:
            return "Child-friendly assessment with personalized age-appropriate questions and drawing analysis. Uses simpler language and concepts."
        case .drawingOnly:
            return "Expression through guided drawing exercises. AI will prompt you to draw specific things, analyze your drawings, and generate a comprehensive emotional assessment."
        }
    }
}

// ResultsView computes and displays category percentages as a simple bar graph.
struct ResultsView: View {
    var responses: [(question: Question, score: Int)]
    var isGreenMode: Bool
    @State private var navigateToDrawing = false
    
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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Results")
                    .font(.largeTitle)
                    .padding()
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
                        .padding()
                    }
                }
                
                NavigationLink(
                    destination: DrawingView(responses: responses, isGreenMode: isGreenMode),
                    isActive: $navigateToDrawing,
                    label: {
                        Button("Proceed to Drawing") {
                            navigateToDrawing = true
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                )
                
                Spacer()
            }
            .padding()
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
}
