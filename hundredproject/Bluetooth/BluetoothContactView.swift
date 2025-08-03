//
//  BluetoothContactView.swift
//  hundredproject
//
//  Created by Duc Tran  on 3/8/25.
//


import SwiftUI

struct BluetoothContactView: View {
    /// Danh sách tin nhắn mock – sau này sẽ gắn với Bluetooth manager.
    @State private var messages: [String] = [
        "Xin chào 👋",
        "Chào bạn!"
    ]
    
    /// Nội dung đang gõ ở ô nhập.
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ----- Khung chat chính -----
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(messages.indices, id: \.self) { idx in
                            HStack {
                                if idx.isMultiple(of: 2) {
                                    Spacer() // tin nhắn bên phải
                                    bubble(text: messages[idx], color: .blue.opacity(0.2))
                                } else {
                                    bubble(text: messages[idx], color: .gray.opacity(0.2))
                                    Spacer()
                                }
                            }
                            .id(idx) // để auto‑scroll tới tin mới
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 12)
                }
                // Auto‑scroll mỗi khi thêm tin
                .onChange(of: messages.count) { _ in
                    withAnimation(.easeOut) {
                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            // ----- Ô nhập & nút gửi -----
            HStack {
                TextField("Nhập tin nhắn…", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                
                Button {
                    send()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                }
                .buttonStyle(.borderless)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }
    
    // MARK: - Helper
    
    private func bubble(text: String, color: Color) -> some View {
        Text(text)
            .padding(10)
            .background(color)
            .cornerRadius(12)
            .foregroundColor(.primary)
    }
    
    private func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(trimmed)
        inputText = ""
    }
}

#Preview {
    BluetoothContactView()
}
