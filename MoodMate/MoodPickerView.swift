import SwiftUI
import PhotosUI

struct MoodPickerView: View {
    let moods = ["😀", "🙂", "😐", "☹️", "😢"]
    @Environment(\.dismiss) var dismiss
    @State private var selectedMood: String? // Selected mood emoji
    @State private var note: String = "" // User note input
    
    @State private var selectedImage: Image? // Image to display
    @State private var isImagePickerPresented = false // Show picker options
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var showCameraPicker = false
    
    var onAdd: (String, String, Image?) -> Void // Completion handler to pass data back

    var body: some View {
        VStack {
            // Top Buttons: Cancel and Add
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                .bold()

                Spacer()

                Button("Add") {
                    if let mood = selectedMood {
                        onAdd(mood, note, selectedImage) // Pass back data
                        dismiss()
                    }
                }
                .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                .bold()
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // Title
            Text("How are you feeling today?")
                .font(.title)
                .bold()
                .padding(.top, 30)

            // Mood Picker
            HStack(spacing: 20) {
                ForEach(moods, id: \.self) { mood in
                    Button(action: {
                        selectedMood = (selectedMood == mood) ? nil : mood
                    }) {
                        ZStack {
                            if selectedMood == mood {
                                Circle()
                                    .fill(Color(red: 75/255, green: 0/255, blue: 130/255))
                                    .frame(width: 60, height: 60)
                            }
                            Text(mood)
                                .font(.system(size: 40))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()

            // Notes Section
            VStack(alignment: .leading, spacing: 20) {
                Text("Notes")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.leading)

                TextEditor(text: $note)
                    .frame(minHeight: 100, maxHeight: 150)
                    .padding(10)
                    .background(Color(red: 75/255, green: 0/255, blue: 130/255).opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.top, 10)

            // Photo Section with tap gesture
            // Photo Section with two options
            VStack(alignment: .leading, spacing: -20) {
                // Fixed Photo Title
                Text("Photo")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.leading)
                    .padding(.top, 30)
                

                // Fixed Container for Image or Buttons
                ZStack {
                    if let image = selectedImage {
                        // Display selected photo
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Fit image without cropping
                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200) // Fixed container size
                            .cornerRadius(10)
                            .onTapGesture {
                                isImagePickerPresented = true // Allow image replacement
                            }
                    } else {
                        // Two buttons: Take Photo and Choose from Gallery
                        VStack(spacing: 15) {
                            Button(action: {
                                sourceType = .camera
                                showCameraPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "camera")
                                        .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                                    Text("Take Photo")
                                        .bold()
                                        .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color(red: 75/255, green: 0/255, blue: 130/255).opacity(0.2))
                            .cornerRadius(10)

                            Button(action: {
                                sourceType = .photoLibrary
                                showCameraPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                        .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                                    Text("Choose from Gallery")
                                        .bold()
                                        .foregroundColor(Color(red: 75/255, green: 0/255, blue: 130/255))
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color(red: 75/255, green: 0/255, blue: 130/255).opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200) // Fixed container size
                .padding(.horizontal)
            }
            .sheet(isPresented: $showCameraPicker) {
                ImagePicker(sourceType: sourceType, selectedImage: $selectedImage)
            }

            

            Spacer()
        }
        .background(Color(red: 230/255, green: 230/255, blue: 250/255).edgesIgnoringSafeArea(.all))
        .actionSheet(isPresented: $isImagePickerPresented) {
            ActionSheet(
                title: Text("Choose Photo Option"),
                buttons: [
                    .default(Text("Take Photo")) {
                        sourceType = .camera
                        showCameraPicker = true
                    },
                    .default(Text("Choose from Library")) {
                        sourceType = .photoLibrary
                        showCameraPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $selectedImage)
        }
    }
}

// MARK: - ImagePicker Helper
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: Image?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = Image(uiImage: uiImage)
            }
            picker.dismiss(animated: true)
        }
    }
}

struct MoodPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodPickerView { mood, note, photo in
            print("Mood: \(mood), Note: \(note), Photo: \(photo != nil ? "Added" : "None")")
        }
    }
}
