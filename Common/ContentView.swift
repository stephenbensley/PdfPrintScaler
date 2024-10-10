//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI
import UtiliKit

// Exceptions thrown during PDF processing. These are in addition to any system errors that may
// occur.
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

// App details used to populate About page.
struct PdfPrintScalerInfo: AboutInfo {
    let appStoreId: Int = 6736712815
    let copyright: String = "© 2024 Stephen E. Bensley"
    let description: String = "Scale & print PDF"
    let gitHubAccount: String = "stephenbensley"
    let gitHubRepo: String = "PdfPrintScaler"
}

// Main content view shared between the app and the action extension.
struct ContentView: View {
    // True if the user is only allowed to print one document, one time before the view exits. This
    // is set to true when the view is loaded from an action extension.
    private let printOnce: Bool
    // Used to dismiss the view.
    private let dismiss: (() -> Void)?
    // URL being processed, nil if user hasn't selected a file yet.
    @State private var url: URL?
    // Document being processed, nil if file hasn't been loaded yet.
    @State private var doc: PDFDocument? = nil
    // Trigger the about page
    @State private var showAbout = false
    // Trigger the error alert.
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Init invoked by app.
    init() {
        self.printOnce = false
        self.dismiss = nil
    }
    
    // Init invoked by action extension.
    init(url: URL, dismiss: @escaping () -> Void) {
        self.printOnce = true
        self.dismiss = dismiss
        self._url = State(initialValue: url)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let doc = doc {
                    // We've successfully loaded a document, so process it.
                    ProcessPdfView(doc: doc, printOnce: printOnce, dismiss: clear)
                } else if url != nil {
                    // We have an URL, but no doc, so we must be loading it in the background.
                    ProgressView("Reading file contents…")
                } else {
                    // We don't even have an url, so prompt the user to select one.
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
            .onAppear { loadPdf() }
            .onChange(of: url) { loadPdf() }
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
    
    // Clear the current URL. If this is the action extension, we dismiss the view (they only get
    // one chance). If this is the app, clear our state, so the user can pick a new file.
    func clear() {
        if let dismiss = dismiss {
            dismiss()
        } else {
            url = nil
            doc = nil
        }
    }
    
    // Loads the PDF in the background.
    func loadPdf() {
        // If we don't have an URL there's nothing to do.
        guard let url = url else { return }
        // Use a task, so we don't stall the UI.
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
    
    // Asynchronously reads data from an URL
    static func readData(from url: URL) async throws -> Data {
        // Read data in a detached task because NSFileCoordinator.coordinate can block.
        let task = Task.detached {
            // If we don't call this, remote file access (e.g., Google Drive) will fail.
            guard url.startAccessingSecurityScopedResource() else { throw PdfError.accessDenied }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Use NSFileCoordinator since cloud-based files may need to be downloaded first.
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
