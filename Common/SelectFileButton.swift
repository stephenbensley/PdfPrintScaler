//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI
import UniformTypeIdentifiers

// Prompts the user to select a PDF file for processing.
struct SelectFileButton: View {
    // URL of selected file.
    @Binding private var url: URL?
    // Trigger system file picker
    @State private var showFilePicker = false
    // Trigger error alert
    @State private var errorMessage = ""
    @State private var showError = false
    
    init(url: Binding<URL?>) {
        self._url = url
    }
    
    var body: some View {
        Button("Select PDF file…") { showFilePicker = true }
            .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    self.url = url
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            .alert("Error Selecting File", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
    }
}

#Preview {
    @Previewable @State var url: URL? = nil
    SelectFileButton(url: $url)
}
