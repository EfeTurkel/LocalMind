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
        HStack(alignment: .top, spacing: 12) {
            if !message.isUser {
                // Grok'un avatarı
                    Image(uiImage: loadAvatar())
                    .resizable()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.outline, lineWidth: 1)
                    )

                // Grok mesajları sola yaslanacak
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedAIModel.capitalized)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    if message.isLoading {
                        LoadingView(selectedModel: message.aiModel)
                    } else {
                        Text(attributedString)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(AppTheme.elevatedBackground)
                            .foregroundColor(AppTheme.textPrimary)
                            .cornerRadius(AppTheme.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                    .stroke(AppTheme.outline)
                            )
                            .textSelection(.enabled)
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 520, alignment: .leading)
                            .gesture(longPressGesture)
                    }
                    
                    Text(formatDate(message.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.subtleText)
                }
                
                Spacer(minLength: 0)
            } else {
                // Kullanıcı mesajları sağa yaslanacak
                Spacer(minLength: 0)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(userName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(attributedString)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(AppTheme.accentGradient)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                .stroke(Color.white.opacity(0.2))
                        )
                        .textSelection(.enabled)
                        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 520, alignment: .trailing)
                        .gesture(longPressGesture)
                    
                    Text(formatDate(message.timestamp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.subtleText)
                }
                
                // Kullanıcının avatarı
                if let uiImage = loadUserPhoto() {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(AppTheme.outline, lineWidth: 1)
                        )
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(AppTheme.textSecondary)
                        .background(
                            Circle()
                                .fill(AppTheme.controlBackground)
                        )
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
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
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Button(action: {
                        showingSelectionToolbar = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showingSelectionToolbar = true
                        }
                    }) {
                        Text("Select")
                            .foregroundColor(AppTheme.textPrimary)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    
                    Button(action: {
                        selectedRange = NSRange(location: 0, length: 0)
                        showingSelectionToolbar = false
                    }) {
                        Text("Done")
                            .foregroundColor(AppTheme.textPrimary)
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(AppTheme.elevatedBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .stroke(AppTheme.outline)
                )
                .cornerRadius(AppTheme.cornerRadius)
                .padding(.horizontal)
                .padding(.bottom, 12)
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