import SwiftUI

struct PersonalizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var avatar: String
    @AppStorage("personality") private var personality = "default"
    @AppStorage("customInstructions") private var customInstructions = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    let personalityOptions = ["default", "friendly", "professional", "humorous"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Avatar") {
                    VStack {
                        if avatar == "xai2_logo" {
                            Image("xai2_logo")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else if let uiImage = loadAvatar() {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Change Avatar")
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                    }
                }
                
                Section("Personality") {
                    Picker("Personality", selection: $personality) {
                        ForEach(personalityOptions, id: \.self) {
                            Text($0.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Custom Instructions") {
                    TextEditor(text: $customInstructions)
                        .frame(height: 150)
                    
                    Text("Enter custom instructions for the AI's behavior and responses.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button(action: {
                        resetToDefaultSettings()
                    }) {
                        Text("Reset to Default Settings")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Personalization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAvatar()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .onChange(of: inputImage) { oldValue, newValue in
                if let inputImage = newValue {
                    saveAvatar(inputImage)
                }
            }
        }
    }
    
    private func saveAvatar(_ image: UIImage? = nil) {
        if let inputImage = image ?? inputImage {
            let imageName = UUID().uuidString
            let imagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(imageName).jpg")
            if let jpegData = inputImage.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: imagePath)
                avatar = imageName
            }
        }
    }
    
    private func loadAvatar() -> UIImage? {
        let imagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(avatar).jpg")
        if let imageData = try? Data(contentsOf: imagePath),
           let uiImage = UIImage(data: imageData) {
            return uiImage
        }
        return nil
    }
    
    private func resetToDefaultSettings() {
        avatar = "xai2_logo"
        personality = "default"
        customInstructions = ""
        
        // Özel avatar resmini sil
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("\(avatar).jpg")
        try? fileManager.removeItem(at: fileURL)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 