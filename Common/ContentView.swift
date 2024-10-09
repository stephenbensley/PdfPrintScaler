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
    case accessDenied
    case invalidData
    case emptyFile
    case unexpected
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            "The file couldn't be opened because you don't have permission to view it."
        case .invalidData:
            "Data in PDF file is invalid or corrupt."
        case .emptyFile:
            "PDF file does not contain any pages."
        case .unexpected:
            "An unexpected error occurred."
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
                    ProgressView("Reading file contents…")
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
        Task {
            do {
                let data = try await Self.readData(from: url)
                guard let doc = PDFDocument(data: data) else { throw PdfError.invalidData }
                guard doc.pageCount > 0 else { throw PdfError.emptyFile }
                self.doc = doc
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    static func readData(from url: URL) async throws -> Data {
        // Read data in a detached task because NSFileCoordinator.coordinate can block.
        let task = Task.detached {
            guard url.startAccessingSecurityScopedResource() else { throw PdfError.accessDenied }
            defer { url.stopAccessingSecurityScopedResource() }
            
            var outerError: NSError? = nil
            var innerError: Error? = nil
            var data: Data? = nil
            NSFileCoordinator().coordinate(
                readingItemAt: url,
                options: .withoutChanges,
                error: &outerError
            ) { url in
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    innerError = error
                }
            }
            if let innerError = innerError { throw innerError }
            if let outerError = outerError { throw outerError }
            guard let data = data else { throw PdfError.unexpected }
            return data
        }
        return try await task.value
    }
}

#Preview {
    ContentView(url: Sample.url, dismiss: { })
}
