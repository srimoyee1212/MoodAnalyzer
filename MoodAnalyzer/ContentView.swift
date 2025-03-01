//
//  ContentView.swift
//  MoodAnalyzer
//
//  Created by Srimoyee Mukhopadhyay on 2/28/25.
//

import SwiftUI

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
}

struct ContentView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [String] = []
    @State private var showDrawingView = false
    
    let questions: [Question] = [
        Question(text: "How are you feeling today?", options: ["Happy", "Anxious", "Sad", "Excited"]),
        Question(text: "What best describes your recent thoughts?", options: ["Organized", "Chaotic", "Creative", "Unfocused"]),
        Question(text: "Which of these colors do you relate to most?", options: ["Red", "Blue", "Green", "Yellow"])
    ]
    
    var body: some View {
        VStack {
            if showDrawingView {
                DrawingView()
            } else {
                Text(questions[currentQuestionIndex].text)
                    .font(.title2)
                    .padding()
                
                ForEach(questions[currentQuestionIndex].options, id: \.self) { option in
                    Button(action: {
                        selectedAnswers.append(option)
                        if currentQuestionIndex < questions.count - 1 {
                            currentQuestionIndex += 1
                        } else {
                            showDrawingView = true
                        }
                    }) {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
