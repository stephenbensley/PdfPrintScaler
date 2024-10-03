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
                ScalablePdfView(pdf: pdf, dismiss: clear)
            } else {
                PdfFilePicker(url: $url)
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
        .alert("Error Opening File", isPresented: $showError) {
            Button("OK") { clear() }
        } message: {
            Text(errorMessage)
        }
        .padding()
    }
    
    func clear() {
        url = nil
        pdf = nil
    }
}

#Preview {
    ContentView()
}
