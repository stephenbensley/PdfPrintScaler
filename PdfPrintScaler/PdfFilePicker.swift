//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI
import UniformTypeIdentifiers
import UtiliKit

// Allows the user to pick a PDF file for processing.
struct PdfFilePicker: View {
    @Binding private var url: URL?
    @State private var showFilePicker = false
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
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
    }
}

#Preview {
    @Previewable @State var url: URL? = nil
    PdfFilePicker(url: $url)
}
