import SwiftUI
import Charts

struct MoodLog: Identifiable {
    let id = UUID() // Unique identifier
    let emoji: String // Selected mood emoji
    let note: String // User-entered note
    let photo: Image? // Optional image
    let date: Date // Date when the log was created
    
}


struct HomeView: View {
    @State private var selectedTab: Tab = .mood
    @State private var showMoodPicker = false // State to show the mood picker
    @State private var moodLogs: [MoodLog] = [
        MoodLog(emoji: "😀", note: "Feeling great!", photo: nil, date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!),
        MoodLog(emoji: "🙂", note: "Good day overall", photo: nil, date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!),
        MoodLog(emoji: "😐", note: "Just an okay day", photo: nil, date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!),
        MoodLog(emoji: "☹️", note: "Feeling a bit down", photo: nil, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
        MoodLog(emoji: "😢", note: "Rough day", photo: nil, date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
        MoodLog(emoji: "🙂", note: "Mood improving!", photo: nil, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        MoodLog(emoji: "😀", note: "Back to happy!", photo: nil, date: Date()) // Today's date
    ]
 // Store list of mood logs

    var body: some View {
        NavigationView {
            VStack {
                // Top Content: Display Logs or Insights
                if selectedTab == .mood {
                    MoodScreen(moodLogs: moodLogs)
                } else {
                    InsightsScreen(moodLogs: moodLogs) // Pass moodLogs to InsightsScreen
                }

                Spacer()

                // Tab Bar
                HStack {
                    TabBarButton(icon: "face.smiling", label: "Mood Log", isSelected: selectedTab == .mood) {
                        selectedTab = .mood
                    }
                    
                    TabBarButton(icon: "chart.bar", label: "Insights", isSelected: selectedTab == .insights) {
                        selectedTab = .insights
                    }
                }
                .frame(height: 80)
                .background(Color(red: 230/255, green: 230/255, blue: 250/255)) // Match background
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.02), radius: 8, x: 20, y: -30)
            }
            .background(
                Color(red: 230/255, green: 230/255, blue: 250/255)
                    .edgesIgnoringSafeArea(.all) // Lavender background
            )
            .navigationTitle(selectedTab == .mood ? "Mood Log" : "Insights")
            .accentColor(Color(red: 75/255, green: 0/255, blue: 130/255)) // Title in Deep Purple
            .toolbar {
                if selectedTab == .mood { // Only show plus button in the mood screen
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showMoodPicker = true // Show mood picker sheet
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                        }
                    }
                }
            }
            .sheet(isPresented: $showMoodPicker) {
                MoodPickerView { emoji, note, photo in
                    let newLog = MoodLog(emoji: emoji, note: note, photo: photo, date: Date()) // Add current date
                    moodLogs.append(newLog) // Append to mood logs list
                }
            }

        }
    }
}

struct MoodScreen: View {
     let moodLogs: [MoodLog]
     
     // Group the logs by date
     private var groupedLogs: [String: [MoodLog]] {
         let formatter = DateFormatter()
         formatter.dateStyle = .medium // Example: Dec 18, 2024
         return Dictionary(grouping: moodLogs, by: { formatter.string(from: $0.date) })
     }
     
     var body: some View {
         ScrollView {
             VStack(alignment: .leading, spacing: 10) {
                 if moodLogs.isEmpty {
                     // Default message if no logs exist
                     Text("No mood logs yet. Tap the '+' to add one!")
                         .font(.headline)
                         .foregroundColor(.gray)
                         .padding()
                 } else {
                     // Group logs by date and display each group
                     ForEach(groupedLogs.sorted(by: { $0.key > $1.key }), id: \.key) { date, logs in
                         VStack(alignment: .leading, spacing: 0) {
                             // Date Header with purple accent background
                             Text(date)
                                 .font(.headline)
                                 .bold()
                                 .foregroundColor(.white)
                                 .frame(maxWidth: .infinity)
                                 .padding(8)
                                 .background(Color(red: 75/255, green: 0/255, blue: 130/255)) // Purple accent color
                                 .cornerRadius(8)
                                 .padding(.horizontal)
                                 .padding(.top, 10)
                             
                             // Display all logs for the current date
                             ForEach(logs) { log in
                                 ZStack(alignment: .topLeading) {
                                     VStack(alignment: .center, spacing: 10) {
                                         // Note centered at the top or Spacer
                                         if !log.note.isEmpty {
                                             Text(log.note)
                                                 .font(.body)
                                                 .foregroundColor(.primary)
                                                 .multilineTextAlignment(.center)
                                                 .padding(.horizontal, 15)
                                                 .padding(.top, 10)
                                         } else {
                                             Spacer()
                                                 .frame(height: 10)
                                         }
                                         
                                         // Photo beneath the note
                                         if let photo = log.photo {
                                             photo
                                                 .resizable()
                                                 .scaledToFit()
                                                 .frame(height: 150)
                                                 .cornerRadius(10)
                                                 .padding(.horizontal, 10)
                                                 .padding(.bottom, 10)
                                         }
                                     }
                                     .frame(maxWidth: .infinity)
                                     .background(Color(red: 75/255, green: 0/255, blue: 130/255).opacity(0.2))
                                     .cornerRadius(10)
                                     .shadow(radius: 2)
                                     
                                     // Emoji on Top-Left
                                     Text(log.emoji)
                                         .font(.system(size: 70))
                                         .offset(x: -20, y: -20)
                                 }
                                 .padding(.horizontal)
                                 .padding(.top, 10)
                             }
                         }
                     }
                 }
             }
             .padding(.horizontal)
         }
     }
}

// Updated InsightsScreen with Bar Chart


struct InsightsScreen: View {
    let moodLogs: [MoodLog]

    private let moodOrder: [String] = ["😢", "☹️", "😐", "🙂", "😀"] // From saddest to happiest
    private let moodColors: [Color] = [
        Color(red: 125/255, green: 75/255, blue: 150/255).opacity(0.2), // Lightest purple (😢)
        Color(red: 100/255, green: 50/255, blue: 150/255).opacity(0.4),
        Color(red: 75/255, green: 0/255, blue: 130/255).opacity(0.6),
        Color(red: 75/255, green: 0/255, blue: 130/255).opacity(0.8),
        Color(red: 75/255, green: 0/255, blue: 130/255) // Darkest purple (😀)
    ]

    // Mood fluctuations data for the past 7 days
    private var moodFluctuations: [(date: String, moodIndex: Int)] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        let filteredLogs = moodLogs.filter { $0.date >= oneWeekAgo }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Example: Mon, Tue

        var moodData: [(String, Int)] = []
        let calendar = Calendar.current

        for i in 0..<7 {
            let currentDate = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let dateString = formatter.string(from: currentDate)
            let moodsOfDay = filteredLogs.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }

            if let latestLog = moodsOfDay.last {
                let moodIndex = moodOrder.firstIndex(of: latestLog.emoji) ?? 2 // Default to "😐"
                moodData.append((dateString, moodIndex))
            } else {
                moodData.append((dateString, -1)) // No data for the day
            }
        }
        return moodData.reversed()
    }

    // Mood count data
    private var moodCounts: [String: Int] {
        var counts = [String: Int]()
        for mood in moodOrder {
            counts[mood] = moodLogs.filter { $0.emoji == mood }.count
        }
        return counts
    }

    // Precomputed slice angles
    private var sliceAngles: [(color: Color, startAngle: Double, endAngle: Double)] {
        let total = max(moodCounts.values.reduce(0, +), 1)
        var cumulativeAngle: Double = 180

        return moodOrder.compactMap { mood in
            let count = moodCounts[mood] ?? 0
            guard count > 0 else { return nil }
            let sliceAngle = Double(count) / Double(total) * 180
            let startAngle = cumulativeAngle
            let endAngle = cumulativeAngle + sliceAngle
            cumulativeAngle += sliceAngle
            return (moodColors[moodOrder.firstIndex(of: mood)!], startAngle, endAngle)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Line Chart Title
                Text("Mood Fluctuations (Past Week)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                    .padding(.leading, 20)
                
                // Line Chart
                Chart {
                    ForEach(Array(moodFluctuations.enumerated()), id: \.offset) { _, data in
                        if data.moodIndex != -1 {
                            LineMark(
                                x: .value("Day", data.date),
                                y: .value("Mood", data.moodIndex)
                            )
                            .symbol {
                                Text(moodOrder[data.moodIndex]) // Display emoji on data points
                                    .font(.title2)
                            }
                            .foregroundStyle(Color(red: 75/255, green: 0/255, blue: 130/255))
                        }
                    }
                }
                .chartYScale(domain: [0, 4])
                .chartYAxis {
                    AxisMarks(position: .leading, values: Array(0...4)) { value in
                        if let intValue = value.as(Int.self), intValue < moodOrder.count {
                            AxisValueLabel {
                                Text(moodOrder[intValue])
                                    .font(.title2)
                            }
                            AxisGridLine()
                                .foregroundStyle(Color(red: 75/255, green: 0/255, blue: 130/255))
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisValueLabel()
                            .foregroundStyle(Color.primary)
                            .offset(y: 10) // Moves x-axis labels downward
                        AxisGridLine()
                            .foregroundStyle(Color(red: 75/255, green: 0/255, blue: 130/255))
                    }
                }
                .frame(height: 250)
                .padding(.horizontal, 20)
                
                // Semi-Circular Chart Title
                Text("Mood Count (Past Week)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                    .padding(.leading, 20)
                
                // Semi-Circular Chart
                ZStack(alignment: .top) // Semi-Circular Chart
            {
                    // Background Rectangle
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .frame(height: 280)
                        .padding(.horizontal, 20)
                    
                    VStack {
                        Spacer()
                        
                        // Total Moods Text and Number (Shifted Lower)
                        VStack(spacing: 5) {
                            Text("Total Moods")
                                .font(.subheadline)
                                .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                                .padding(.top, 10) // Push slightly down
                            Text("\(moodCounts.values.reduce(0, +))")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                                .padding(.bottom, 10) // More padding to move it down
                        }
                        
                        // Semi-Circular Chart
                        GeometryReader { geometry in
                            let centerX = geometry.size.width / 2
                            let radius = geometry.size.width / 1.5
                            
                            ZStack {
                                ForEach(sliceAngles, id: \.startAngle) { slice in
                                    ArcShape(
                                        startAngle: .degrees(slice.startAngle),
                                        endAngle: .degrees(slice.endAngle)
                                    )
                                    .fill(slice.color)
                                }
                            }
                            .frame(width: geometry.size.width, height: radius)
                            .position(x: centerX, y: radius / 2)
                        }
                        .padding(.top, -100)
                        .frame(height: 110) // Reduced height for more space
                        
                        // Emojis and Counts Section (Reduced Spacing and Moved Up)
                        HStack(spacing: 15) { // Decreased spacing to 15
                            ForEach(0..<moodOrder.count, id: \.self) { index in
                                VStack(spacing: 4) { // Slightly tighter vertical spacing
                                    Circle()
                                        .fill(moodColors[index])
                                        .frame(width: 36, height: 36) // Slightly smaller emoji circles
                                        .overlay(
                                            Text(moodOrder[index])
                                                .font(.title3)
                                                .foregroundColor(.white)
                                        )
                                    Text("\(moodCounts[moodOrder[index]] ?? 0)")
                                        .font(.footnote) // Smaller font for counts
                                        .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                                }
                            }
                        }
                        .padding(.top, -5) // Move the entire emoji section upwards
                        .padding(.bottom, 10) // Maintain a clean bottom margin
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 280) // Align with the rectangle's height
                }



                .padding(.horizontal, 20)
            }

                // Emojis and Counts in a Straight Line
             
                .padding(.horizontal, 20)
            }
            .background(Color(red: 230/255, green: 230/255, blue: 250/255))
        }
    }


// ArcShape for creating slices
struct ArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        return path
    }
}







struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(isSelected ? Color(red: 75/255, green: 0/255, blue: 130/255) : .gray)
                Text(label)
                    .font(.footnote)
                    .foregroundColor(isSelected ? Color(red: 75/255, green: 0/255, blue: 130/255) : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

enum Tab {
    case mood
    case insights
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
