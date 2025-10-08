import SwiftUI

struct AIModeSelector: View {
    @Binding var selectedMode: AIMode
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedAIMode") private var storedModeRaw: String = AIMode.general.rawValue
    
    var body: some View {
        NavigationView {
            List(AIMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                    storedModeRaw = mode.rawValue
                    dismiss()
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: mode.icon)
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.tint)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mode.rawValue)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                            
                            Text(mode.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedMode == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select AI Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 