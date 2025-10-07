import SwiftUI

struct MessageView: View {
    let message: Message
    @AppStorage("avatar") private var avatar = "xai2_logo"
    @AppStorage("userName") private var userName = ""
    @AppStorage("userPhoto") private var userPhoto = ""
    @AppStorage("selectedAIModel") private var selectedAIModel: String = "grok-beta"
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingShareSheet = false
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showingSelectionToolbar = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isUser {
                // Grok'un avatarı
                    Image(uiImage: loadAvatar())
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                // Grok mesajları sola yaslanacak
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedAIModel.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if message.isLoading {
                        LoadingView(selectedModel: message.aiModel)
                    } else {
                        Text(attributedString)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                            .textSelection(.enabled)
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 520, alignment: .leading)
                            .gesture(longPressGesture)
                    }
                    
                    Text(formatDate(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 0)
            } else {
                // Kullanıcı mesajları sağa yaslanacak
                Spacer(minLength: 0)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(userName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(attributedString)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .textSelection(.enabled)
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 520, alignment: .trailing)
                        .gesture(longPressGesture)
                    
                    Text(formatDate(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Kullanıcının avatarı
                if let uiImage = loadUserPhoto() {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .overlay(selectionToolbar)
    }
    
    private var attributedString: AttributedString {
        var attributedString = AttributedString(message.content)
        if selectedRange.length > 0,
           let range = Range(selectedRange, in: message.content) {
            let attributedRange = attributedString.characters.index(attributedString.startIndex, offsetBy: range.lowerBound.utf16Offset(in: message.content))..<attributedString.characters.index(attributedString.startIndex, offsetBy: range.upperBound.utf16Offset(in: message.content))
            attributedString[attributedRange].backgroundColor = .blue.opacity(0.2)
        }
        return attributedString
    }
    
    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in
                showingSelectionToolbar = true
            }
    }
    
    @ViewBuilder
    private var selectionToolbar: some View {
        if showingSelectionToolbar {
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        if let range = Range(selectedRange, in: message.content) {
                            UIPasteboard.general.string = String(message.content[range])
                        }
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        showingSelectionToolbar = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showingSelectionToolbar = true
                        }
                    }) {
                        Text("Select")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    Button(action: {
                        selectedRange = NSRange(location: 0, length: 0)
                        showingSelectionToolbar = false
                    }) {
                        Text("Done")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: showingSelectionToolbar)
        }
    }
    
    private func loadAvatar() -> UIImage {
        let imagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(avatar).jpg")
        if let imageData = try? Data(contentsOf: imagePath),
           let uiImage = UIImage(data: imageData) {
            return uiImage
        }
        return UIImage(named: "xai2_logo") ?? UIImage()
    }
    
    private func loadUserPhoto() -> UIImage? {
        if let data = Data(base64Encoded: userPhoto) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

extension NSRange {
    func range(in string: String) -> Range<String.Index>? {
        guard let rangeStart = string.utf16.index(string.utf16.startIndex, offsetBy: location, limitedBy: string.utf16.endIndex),
              let rangeEnd = string.utf16.index(rangeStart, offsetBy: length, limitedBy: string.utf16.endIndex) else {
            return nil
        }
        
        guard let start = String.Index(rangeStart, within: string),
              let end = String.Index(rangeEnd, within: string) else {
            return nil
        }
        
        return start..<end
    }
}

// Removed custom subscript that shadowed default behavior and risked recursion

// ShareSheet için UIKit wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 