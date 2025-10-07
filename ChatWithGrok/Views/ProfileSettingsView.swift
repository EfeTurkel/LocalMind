import SwiftUI

struct ProfileSettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("userPhoto") private var userPhoto = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Photo") {
                    VStack {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let uiImage = loadUserPhoto() {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section("Name") {
                    TextField("Enter your name", text: $userName)
                }
            }
            .navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveUserPhoto()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .onChange(of: inputImage) { oldValue, newValue in
                if let inputImage = newValue {
                    saveUserPhoto(inputImage)
                }
            }
        }
    }
    
    private func saveUserPhoto(_ image: UIImage? = nil) {
        if let inputImage = image ?? inputImage {
            if let jpegData = inputImage.jpegData(compressionQuality: 0.8) {
                userPhoto = jpegData.base64EncodedString()
            }
        }
    }
    
    private func loadUserPhoto() -> UIImage? {
        if let data = Data(base64Encoded: userPhoto) {
            return UIImage(data: data)
        }
        return nil
    }
} 