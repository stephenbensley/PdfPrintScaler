//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI
import UtiliKit

enum PdfError: LocalizedError {
    case invalidData
    case emptyFile
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            "Data in PDF file is invalid or corrupt."
        case .emptyFile:
            "PDF file does not contain any pages."
        }
    }
}

struct PdfPrintScalerInfo: AboutInfo {
    let appStoreId: Int = 6575389687
    let copyright: String = "© 2024 Stephen E. Bensley"
    let description: String = "Scale & print PDF"
    let gitHubAccount: String = "stephenbensley"
    let gitHubRepo: String = "PdfPrintScaler"
}

struct ContentView: View {
    private let printOnce: Bool
    private let dismiss: (() -> Void)?
    @State private var url: URL?
    @State private var doc: PDFDocument? = nil
    @State private var showAbout = false
    @State private var showError = false
    @State private var errorMessage = ""

    init() {
        self.printOnce = false
        self.dismiss = nil
    }
    
    init(url: URL, dismiss: @escaping () -> Void) {
        self.printOnce = true
        self.dismiss = dismiss
        self._url = State(initialValue: url)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let doc = doc {
                    ProcessPdfView(doc: doc, printOnce: printOnce, dismiss: clear)
                } else if url != nil {
                    ProgressView()
                } else {
                    SelectFileButton(url: $url)
                }
            }
            .navigationTitle("PDF Print Scaler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    showAbout = true
                 } label: {
                    Label("About", systemImage: "ellipsis.circle")
                }
            }
            .onAppear {
                loadPdf()
            }
            .onChange(of: url) {
                loadPdf()
            }
            .alert("Error Opening File", isPresented: $showError) {
                Button("OK") { clear() }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showAbout) {
                AboutView(info: PdfPrintScalerInfo())
            }
            .padding()
        }
    }
    
    func clear() {
        if let dismiss = dismiss {
            dismiss()
        } else {
            url = nil
            doc = nil
        }
    }
    
    func loadPdf() {
        guard let url = url else { return }
        do {
            let data = try Data(contentsOf: url)
            guard let doc = PDFDocument(data: data) else { throw PdfError.invalidData }
            guard doc.pageCount > 0 else { throw PdfError.emptyFile }
            self.doc = doc
        }
        catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
