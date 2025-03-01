//
//  ContentView.swift
//  MoodAnalyzer
//
//  Created by Srimoyee Mukhopadhyay on 2/28/25.
//
import SwiftUI

// Define the Question struct with category and reverse scoring flag.
struct Question: Identifiable {
    let id = UUID()
    let text: String
    let category: String
    let isReverseScored: Bool
}

struct ContentView: View {
    @State private var currentQuestionIndex = 0
    // Store responses as a tuple of Question and its (adjusted) numeric score.
    @State private var responses: [(question: Question, score: Int)] = []
    @State private var showResultsView = false
    @State private var showDrawingView = false

    let questions: [Question] = [
        // Resilience & Coping (12 Questions) – All phrased positively.
        Question(text: "I handle difficult situations well.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I get better tomorrow even after a tiring day.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I have hobbies that help me feel better.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I can easily manage my emotions.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I find it easy to bounce back after setbacks.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I am confident in my abilities.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I am resilient when facing unexpected challenges.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I actively seek opportunities for self-improvement.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I have clear goals and ambitions for my future.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I maintain a balanced lifestyle.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I am optimistic about overcoming obstacles.", category: "Resilience & Coping", isReverseScored: false),
        Question(text: "I trust my ability to solve problems.", category: "Resilience & Coping", isReverseScored: false),
        
        // Mental Health & Mood (6 Questions)
        // Negative phrasing (reverse scoring) is applied to items indicating poor mood.
        Question(text: "I experience feelings of depression frequently.", category: "Mental Health & Mood", isReverseScored: true),
        Question(text: "I have a strong sense of self-worth.", category: "Mental Health & Mood", isReverseScored: false),
        Question(text: "I sometimes feel low without a clear reason.", category: "Mental Health & Mood", isReverseScored: true),
        Question(text: "I occasionally feel like giving up.", category: "Mental Health & Mood", isReverseScored: true),
        Question(text: "I struggle with self-doubt regularly.", category: "Mental Health & Mood", isReverseScored: true),
        Question(text: "I experience mood swings that affect my day.", category: "Mental Health & Mood", isReverseScored: true),
        
        // Social Connection & Loneliness (10 Questions)
        // Items that indicate negative social feelings are reverse scored.
        Question(text: "I often feel lonely.", category: "Social Connection & Loneliness", isReverseScored: true),
        Question(text: "I enjoy social interactions with others.", category: "Social Connection & Loneliness", isReverseScored: false),
        Question(text: "I often worry about what others think of me.", category: "Social Connection & Loneliness", isReverseScored: true),
        Question(text: "I often feel anxious in challenging social situations.", category: "Social Connection & Loneliness", isReverseScored: true),
        Question(text: "I find it hard to trust people around me.", category: "Social Connection & Loneliness", isReverseScored: true),
        Question(text: "I sometimes feel isolated from those around me.", category: "Social Connection & Loneliness", isReverseScored: true),
        Question(text: "I feel disconnected from my community.", category: "Social Connection & Loneliness", isReverseScored: true),
        Question(text: "I often feel misunderstood by others.", category: "Social Connection & Loneliness", isReverseScored: true),
        Question(text: "I enjoy spending time alone to recharge.", category: "Social Connection & Loneliness", isReverseScored: false),
        Question(text: "I am comfortable sharing my feelings with others.", category: "Social Connection & Loneliness", isReverseScored: false),
        
        // Satisfaction & Contentment (12 Questions)
        // Some items are reverse scored if they indicate negative feelings.
        Question(text: "I am satisfied with my life.", category: "Satisfaction & Contentment", isReverseScored: false),
        Question(text: "I feel hopeful about my future.", category: "Satisfaction & Contentment", isReverseScored: false),
        Question(text: "I believe my life is under control.", category: "Satisfaction & Contentment", isReverseScored: false),
        Question(text: "I struggle to find motivation in daily tasks.", category: "Satisfaction & Contentment", isReverseScored: true),
        Question(text: "I feel energized by my daily activities.", category: "Satisfaction & Contentment", isReverseScored: false),
        Question(text: "I am content with my personal relationships.", category: "Satisfaction & Contentment", isReverseScored: false),
        Question(text: "I feel overwhelmed by stress from time to time.", category: "Satisfaction & Contentment", isReverseScored: true),
        Question(text: "I am satisfied with my work or studies.", category: "Satisfaction & Contentment", isReverseScored: false),
        Question(text: "I often feel a lack of purpose in my daily routines.", category: "Satisfaction & Contentment", isReverseScored: true),
        Question(text: "I frequently doubt the decisions I make.", category: "Satisfaction & Contentment", isReverseScored: true),
        Question(text: "I find joy in the small things in life.", category: "Satisfaction & Contentment", isReverseScored: false),
        Question(text: "I am proud of my personal achievements.", category: "Satisfaction & Contentment", isReverseScored: false),
        
        // Anxiety & Stress Management (6 Questions)
        // Negative indicators are reverse scored.
        Question(text: "I often feel anxious in high-pressure situations.", category: "Anxiety & Stress Management", isReverseScored: true),
        Question(text: "I find it difficult to relax when under stress.", category: "Anxiety & Stress Management", isReverseScored: true),
        Question(text: "I am aware of the physical symptoms of stress in my body.", category: "Anxiety & Stress Management", isReverseScored: true),
        Question(text: "I feel overwhelmed by unexpected changes.", category: "Anxiety & Stress Management", isReverseScored: true),
        Question(text: "I actively use techniques to manage my stress.", category: "Anxiety & Stress Management", isReverseScored: false),
        Question(text: "I sometimes struggle to calm down after a stressful event.", category: "Anxiety & Stress Management", isReverseScored: true),
        
        // Mindfulness & Emotional Regulation (6 Questions) – All phrased positively.
        Question(text: "I am aware of my emotions in the present moment.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I practice mindfulness or meditation regularly.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I can easily identify when I am becoming emotionally overwhelmed.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I make a conscious effort to accept my feelings without judgment.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I feel in control of my emotional reactions.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I take time to reflect on my thoughts and emotions daily.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        
        // Sleep & Physical Health (6 Questions) – All phrased positively.
        Question(text: "I get enough sleep to feel rested each day.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I maintain a regular sleep schedule.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I notice a strong connection between my physical health and my mood.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I engage in physical activities that boost my energy.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I pay attention to my body’s signals of fatigue.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I prioritize my physical health as part of my overall well-being.", category: "Sleep & Physical Health", isReverseScored: false),
        
        // Work-Life Balance (6 Questions) – All phrased positively.
        Question(text: "I am able to separate work or study time from personal time.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I feel that my work-life balance is well-managed.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I take sufficient breaks during my work or study sessions.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I set boundaries to protect my personal time.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I am satisfied with how I manage my professional and personal responsibilities.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I find time for leisure and relaxation despite my busy schedule.", category: "Work-Life Balance", isReverseScored: false)
    ]
    
    
    // Likert scale options.
    let likertOptions = ["Strongly Agree", "Agree", "Unsure", "Disagree", "Strongly Disagree"]
    
    // Mapping Likert responses to numeric scores.
    let scoreMapping: [String: Int] = [
        "Strongly Agree": 5,
        "Agree": 4,
        "Unsure": 3,
        "Disagree": 2,
        "Strongly Disagree": 1
    ]
    
    var body: some View {
        VStack {
            if showDrawingView {
                // Move to drawing view.
                DrawingView()
            } else if showResultsView {
                // Results view with a button to proceed to drawing.
                VStack {
                    ResultsView(responses: responses)
                    Button(action: {
                        showDrawingView = true
                    }) {
                        Text("Proceed to Drawing")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            } else {
                // Check to prevent crashes when there are no questions.
                if currentQuestionIndex < questions.count {
                    Text(questions[currentQuestionIndex].text)
                        .font(.title2)
                        .padding()
                    
                    ForEach(likertOptions, id: \.self) { option in
                        Button(action: {
                            if let score = scoreMapping[option] {
                                // Adjust score for reverse scored questions.
                                let finalScore = questions[currentQuestionIndex].isReverseScored ? (6 - score) : score
                                responses.append((question: questions[currentQuestionIndex], score: finalScore))
                            }
                            if currentQuestionIndex < questions.count - 1 {
                                currentQuestionIndex += 1
                            } else {
                                showResultsView = true
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
                } else {
                    // Fallback if no questions are available.
                    Button("No questions available. Proceed to Drawing") {
                        showResultsView = true
                    }
                }
            }
        }
        .padding()
    }
}

// ResultsView computes and displays category percentages as a simple bar graph.
struct ResultsView: View {
    var responses: [(question: Question, score: Int)]
    
    // Compute percentage scores for each category.
    var categoryPercentages: [String: Double] {
        var dict: [String: (sum: Int, count: Int)] = [:]
        
        for response in responses {
            let cat = response.question.category
            dict[cat, default: (0, 0)].sum += response.score
            dict[cat, default: (0, 0)].count += 1
        }
        
        var percentages: [String: Double] = [:]
        for (cat, data) in dict {
            let maxScore = data.count * 5
            let percentage = (Double(data.sum) / Double(maxScore)) * 100.0
            percentages[cat] = percentage
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
                                    .fill(Color.blue)
                                    .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 20)
                            }
                            .frame(height: 20)
                        }
                        .padding()
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
