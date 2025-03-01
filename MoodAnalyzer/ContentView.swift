//
//  ContentView.swift
//  MoodAnalyzer
//
//  Updated with Final Report Integration
//

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
            
            NavigationLink(
                destination: MainQuestionsView(isGreenMode: selectedMode == .green),
                isActive: $navigateToMain,
                label: {
                    Button("Continue") {
                        // When the user taps Continue, trigger navigation.
                        navigateToMain = true
                        print("Mode selected: \(selectedMode.rawValue)")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                })
        }
        .padding()
    }
}

// MainQuestionsView is the main flow (questions, results, drawing) that uses the chosen mode.
struct MainQuestionsView: View {
    let isGreenMode: Bool

    // Your existing state variables and question arrays.
    @State private var currentQuestionIndex = 0
    @State private var responses: [(question: Question, score: Int)] = []
    @State private var showResultsView = false
    
    // Regular Questions (64 Questions)
    let regularQuestions: [Question] = [
        // Resilience & Coping (12 Questions)
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
        Question(text: "I experience feelings of depression frequently.", category: "Mental Health & Mood", isReverseScored: true),
        Question(text: "I have a strong sense of self-worth.", category: "Mental Health & Mood", isReverseScored: false),
        Question(text: "I sometimes feel low without a clear reason.", category: "Mental Health & Mood", isReverseScored: true),
        Question(text: "I occasionally feel like giving up.", category: "Mental Health & Mood", isReverseScored: true),
        Question(text: "I struggle with self-doubt regularly.", category: "Mental Health & Mood", isReverseScored: true),
        Question(text: "I experience mood swings that affect my day.", category: "Mental Health & Mood", isReverseScored: true),
        
        // Social Connection & Loneliness (10 Questions)
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
        Question(text: "I often feel anxious in high-pressure situations.", category: "Anxiety & Stress Management", isReverseScored: true),
        Question(text: "I find it difficult to relax when under stress.", category: "Anxiety & Stress Management", isReverseScored: true),
        Question(text: "I am aware of the physical symptoms of stress in my body.", category: "Anxiety & Stress Management", isReverseScored: true),
        Question(text: "I feel overwhelmed by unexpected changes.", category: "Anxiety & Stress Management", isReverseScored: true),
        Question(text: "I actively use techniques to manage my stress.", category: "Anxiety & Stress Management", isReverseScored: false),
        Question(text: "I sometimes struggle to calm down after a stressful event.", category: "Anxiety & Stress Management", isReverseScored: true),
        
        // Mindfulness & Emotional Regulation (6 Questions)
        Question(text: "I am aware of my emotions in the present moment.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I practice mindfulness or meditation regularly.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I can easily identify when I am becoming emotionally overwhelmed.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I make a conscious effort to accept my feelings without judgment.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I feel in control of my emotional reactions.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        Question(text: "I take time to reflect on my thoughts and emotions daily.", category: "Mindfulness & Emotional Regulation", isReverseScored: false),
        
        // Sleep & Physical Health (6 Questions)
        Question(text: "I get enough sleep to feel rested each day.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I maintain a regular sleep schedule.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I notice a strong connection between my physical health and my mood.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I engage in physical activities that boost my energy.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I pay attention to my body's signals of fatigue.", category: "Sleep & Physical Health", isReverseScored: false),
        Question(text: "I prioritize my physical health as part of my overall well-being.", category: "Sleep & Physical Health", isReverseScored: false),
        
        // Work-Life Balance (6 Questions)
        Question(text: "I am able to separate work or study time from personal time.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I feel that my work-life balance is well-managed.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I take sufficient breaks during my work or study sessions.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I set boundaries to protect my personal time.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I am satisfied with how I manage my professional and personal responsibilities.", category: "Work-Life Balance", isReverseScored: false),
        Question(text: "I find time for leisure and relaxation despite my busy schedule.", category: "Work-Life Balance", isReverseScored: false)
    ]
    
    // Kid-friendly Questions (Green Mode)
    let kidQuestions: [Question] = [
        // Feeling Alone & Making Friends (7 Questions)
        Question(text: "After a long school day, do you sometimes feel like you're all by yourself even when other kids are around?", category: "Feeling Alone & Making Friends", isReverseScored: true),
        Question(text: "When it's lunchtime, do you sometimes wish you had someone to share your snack or story with?", category: "Feeling Alone & Making Friends", isReverseScored: true),
        Question(text: "On the playground, do you sometimes feel like you're watching others play instead of joining in?", category: "Feeling Alone & Making Friends", isReverseScored: true),
        Question(text: "Have you ever wanted to start your own club because you felt like no one really understood you?", category: "Feeling Alone & Making Friends", isReverseScored: true),
        Question(text: "During group activities, do you sometimes feel left out or that your ideas aren't heard?", category: "Feeling Alone & Making Friends", isReverseScored: true),
        Question(text: "When recess is over, do you miss talking with a friend or a buddy?", category: "Feeling Alone & Making Friends", isReverseScored: false),
        Question(text: "After a fun playdate, do you feel happy and close to your friends?", category: "Feeling Alone & Making Friends", isReverseScored: false),
        
        // Happy Days & Contentment (7 Questions)
        Question(text: "When you wake up and see a bright morning, do you feel really happy about the day ahead?", category: "Happy Days & Contentment", isReverseScored: false),
        Question(text: "After playing your favorite game, do you feel that your day was extra special?", category: "Happy Days & Contentment", isReverseScored: false),
        Question(text: "When you spend time with your family, do you feel warm and loved?", category: "Happy Days & Contentment", isReverseScored: false),
        Question(text: "Do little things, like finishing a drawing or winning a small prize, make you feel really proud?", category: "Happy Days & Contentment", isReverseScored: false),
        Question(text: "After someone helps you out, do you feel thankful and smile a lot?", category: "Happy Days & Contentment", isReverseScored: false),
        Question(text: "When you learn something new at school or at home, does it make you feel excited?", category: "Happy Days & Contentment", isReverseScored: false),
        Question(text: "Do you often imagine fun adventures or cool things you want to do when you grow up?", category: "Happy Days & Contentment", isReverseScored: false),
        
        // Staying Strong & Focused (7 Questions)
        Question(text: "When your homework seems hard, do you try extra hard to finish it, even if it takes time?", category: "Staying Strong & Focused", isReverseScored: false),
        Question(text: "During team games or projects, do you find it easy to take charge and keep going?", category: "Staying Strong & Focused", isReverseScored: false),
        Question(text: "If you set a goal, like reading a whole book, do you keep working on it even if it feels long?", category: "Staying Strong & Focused", isReverseScored: false),
        Question(text: "When learning something new, like riding a bike, do you keep trying until you get it right?", category: "Staying Strong & Focused", isReverseScored: false),
        Question(text: "When it's time to focus, do you find it easy to ignore fun distractions around you?", category: "Staying Strong & Focused", isReverseScored: false),
        Question(text: "If a task feels tricky, do you see it as a fun challenge to overcome?", category: "Staying Strong & Focused", isReverseScored: false),
        Question(text: "When you start a project, do you feel proud to finish it, even if it takes a little while?", category: "Staying Strong & Focused", isReverseScored: false),
        
        // Feeling Blue & Sad Days (7 Questions)
        Question(text: "On a day when nothing seems to go right, do you sometimes feel like you're stuck in a rainy mood?", category: "Feeling Blue & Sad Days", isReverseScored: true),
        Question(text: "When you miss out on playing with your friends, do you feel extra sad?", category: "Feeling Blue & Sad Days", isReverseScored: true),
        Question(text: "After a busy day, do you sometimes feel too quiet or down even when you're with family?", category: "Feeling Blue & Sad Days", isReverseScored: true),
        Question(text: "Even when there are lots of people around, do you ever feel like something's missing inside?", category: "Feeling Blue & Sad Days", isReverseScored: true),
        Question(text: "When you feel really sad, do you sometimes cry and wonder why?", category: "Feeling Blue & Sad Days", isReverseScored: true),
        Question(text: "After a rough day, do you feel like your smile is hiding somewhere deep inside?", category: "Feeling Blue & Sad Days", isReverseScored: true),
        Question(text: "Do you sometimes wish you could get a big, warm hug to make the sad feelings go away?", category: "Feeling Blue & Sad Days", isReverseScored: false),
        
        // Worry & Nervous Moments (7 Questions)
        Question(text: "Before a big test or game, do you sometimes feel butterflies in your tummy?", category: "Worry & Nervous Moments", isReverseScored: false),
        Question(text: "At night, do you ever feel a bit scared even if nothing bad is around?", category: "Worry & Nervous Moments", isReverseScored: true),
        Question(text: "When you try something new, like a new class or activity, do you feel nervous about it?", category: "Worry & Nervous Moments", isReverseScored: false),
        Question(text: "On a super important day, do you sometimes worry too much about what might happen?", category: "Worry & Nervous Moments", isReverseScored: true),
        Question(text: "Do you feel like a little worry cloud follows you around during busy days?", category: "Worry & Nervous Moments", isReverseScored: true),
        Question(text: "When you feel worried, do you have a fun trick (like deep breaths or imagining a happy place) to help you calm down?", category: "Worry & Nervous Moments", isReverseScored: false),
        Question(text: "When you feel a little nervous, do you sometimes laugh it off or find a silly way to feel better?", category: "Worry & Nervous Moments", isReverseScored: false),
        
        // Bouncing Back & Finding Fun Solutions (7 Questions)
        Question(text: "When you trip or fall during play, do you quickly get up and try again with a smile?", category: "Bouncing Back & Finding Fun Solutions", isReverseScored: false),
        Question(text: "If your art project doesn't turn out right, do you find a fun way to make it better?", category: "Bouncing Back & Finding Fun Solutions", isReverseScored: false),
        Question(text: "After a tough day at school, do you have a secret way to turn it into a fun evening?", category: "Bouncing Back & Finding Fun Solutions", isReverseScored: false),
        Question(text: "When you face a problem, do you sometimes imagine you're a superhero who can solve anything?", category: "Bouncing Back & Finding Fun Solutions", isReverseScored: false),
        Question(text: "After a mistake or a messy moment, do you try to laugh it off and start fresh?", category: "Bouncing Back & Finding Fun Solutions", isReverseScored: false),
        Question(text: "When things go wrong, do you think of a clever idea that makes you feel better?", category: "Bouncing Back & Finding Fun Solutions", isReverseScored: false),
        Question(text: "Do you believe that every day can end with something fun or happy, even if it started off rough?", category: "Bouncing Back & Finding Fun Solutions", isReverseScored: false)
    ]
    
    var questions: [Question] {
        isGreenMode ? kidQuestions : regularQuestions
    }
    
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
            Text("Mode: \(isGreenMode ? "Green Mode" : "Regular Mode")")
                .font(.caption)
                .foregroundColor(.gray)
            
            if showResultsView {
                ResultsView(responses: responses, isGreenMode: isGreenMode)
            } else {
                // ✅ Progress Bar for completed questions
                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 200)
                    .padding()
                
                Text("\(Int((Double(currentQuestionIndex + 1) / Double(questions.count)) * 100))% completed")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(questions[currentQuestionIndex].text)
                    .font(.title2)
                    .padding()
                
                ForEach(likertOptions, id: \.self) { option in
                    Button(action: {
                        if let score = scoreMapping[option] {
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
            }
        }
        .padding()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
