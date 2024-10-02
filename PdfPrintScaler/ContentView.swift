//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI

struct ContentView: View {
    @State private var url: URL?
    @State private var pdf: ScalablePdf?
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Text("PDF Print Scaler")
                .font(.title)
            if let pdf = pdf {
                ScalablePdfView(pdf: pdf, dismiss: { })
            } else {
                PdfFilePicker(url: $url)
            }
        }
        .onChange(of: url) {
            guard let url = url else { return }
            if let pdf = ScalablePdf(url: url) {
                self.pdf = pdf
            } else {
                errorMessage = "Unable to open \(url)."
                showError = true
            }
        }
        .alert("Error Opening File", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
