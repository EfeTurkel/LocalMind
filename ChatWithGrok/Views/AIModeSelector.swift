import SwiftUI

struct AIModeSelector: View {
    @Binding var selectedMode: AIMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(AIMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                    dismiss()
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: mode.icon)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mode.rawValue)
                                .font(.headline)
                            
                            Text(mode.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedMode == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
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