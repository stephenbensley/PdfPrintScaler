//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI
import UniformTypeIdentifiers
import UtiliKit

// Allows the user to pick a PDF file for processing.
struct PdfFilePicker: View {
    @Binding private var doc: PDFDocument?
    @State private var showFilePicker = false
    @State private var errorMessage = ""
    @State private var showError = false
    // User letter-sized aspect ratio for the placeholder frame.
    private let aspectRatio: CGFloat = 8.5/11.0
    
    init(doc: Binding<PDFDocument?>) {
        self._doc = doc
    }
    
    var body: some View {
        GeometryReader { proxy in
            Button("Select PDF file…") { showFilePicker = true }
                .frame(size: proxy.size)
                .border(Color.red)
         }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
            switch result {
            case .success(let url):
                if let doc = PDFDocument(url: url) {
                    self.doc = doc
                } else {
                    errorMessage = "Unable to open \(url)."
                    showError = true
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        .alert("Error Opening File", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    @Previewable @State var doc: PDFDocument? = nil
    PdfFilePicker(doc: $doc)
}
