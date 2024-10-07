//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI
import UtiliKit

struct PdfPrintScalerInfo: AboutInfo {
    let appStoreId: Int = 6575389687
    let copyright: String = "© 2024 Stephen E. Bensley"
    let description: String = "Scale & print PDF"
    let gitHubAccount: String = "stephenbensley"
    let gitHubRepo: String = "PdfPrintScaler"
}

struct ContentView: View {
    private let dismiss: (() -> Void)?
    @State private var url: URL?
    @State private var pdf: ScalablePdf? = nil
    @State private var showAbout = false
    @State private var showError = false
    @State private var errorMessage = ""

    init() {
        self.dismiss = nil
    }
    
    init(url: URL, dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
        self._url = State(initialValue: url)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let pdf = pdf {
                    ScalablePdfView(pdf: pdf, dismiss: clear)
                } else if url != nil {
                    ProgressView()
                } else {
                    PdfFilePicker(url: $url)
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
            pdf = nil
        }
    }
    
    func loadPdf() {
        guard let url = url else { return }
        do {
            pdf = try ScalablePdf(url: url)
        }
        catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
