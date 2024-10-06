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
    @State private var url: URL?
    @State private var pdf: ScalablePdf?
    @State private var showAbout = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Group {
                if let pdf = pdf {
                    ScalablePdfView(pdf: pdf, dismiss: clear)
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
            .onChange(of: url) {
                guard let url = url else { return }
                do {
                    pdf = try ScalablePdf(url: url)
                }
                catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView(info: PdfPrintScalerInfo())
            }
            .alert("Error Opening File", isPresented: $showError) {
                Button("OK") { clear() }
            } message: {
                Text(errorMessage)
            }
            .padding()
        }
    }
    
    func clear() {
        url = nil
        pdf = nil
    }
}

#Preview {
    ContentView()
}
