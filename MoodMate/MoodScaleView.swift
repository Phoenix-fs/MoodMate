import SwiftUI

struct MoodScaleView: View {
    // Define possible moods
    let moods = [
        ("face.smiling", "rad", Color.purple),
        ("face.smiling.fill", "good", Color.pink),
        ("face.neutral", "meh", Color.orange),
        ("face.frown", "bad", Color.yellow),
        ("face.sad", "awful", Color.green)
    ]
    
    @State private var selectedMood: Int? = nil
    
    var body: some View {
        VStack {
            Text("How are you?")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Mood Selection Row
            HStack(spacing: 20) {
                ForEach(moods.indices, id: \.self) { index in
                    VStack {
                        Button(action: {
                            selectedMood = index
                        }) {
                            Image(systemName: moods[index].0)
                                .font(.system(size: 40))
                                .foregroundColor(selectedMood == index ? moods[index].2 : .gray)
                                .scaleEffect(selectedMood == index ? 1.2 : 1.0)
                                .animation(.spring(), value: selectedMood)
                        }
                        
                        Text(moods[index].1.capitalized)
                            .font(.footnote)
                            .foregroundColor(selectedMood == index ? moods[index].2 : .gray)
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all)) // Match dark theme
    }
}

struct MoodScaleView_Previews: PreviewProvider {
    static var previews: some View {
        MoodScaleView()
    }
}
