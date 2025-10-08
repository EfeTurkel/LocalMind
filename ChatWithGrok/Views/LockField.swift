//
//  LockField.swift
//  LockMind
//
//  Created for LockMind
//

import SwiftUI

struct LockField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    @Previewable @State var sampleText = ""
    return LockField("Enter your API key", text: $sampleText)
        .padding()
}
