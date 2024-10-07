//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI

// Main view for the Scaled Print functionality -- shared between the app and the extension.
struct ScalablePdfView: View {
    private let doc: PDFDocument
    private let printOnce: Bool
    private let dismiss: () -> Void
    @State var scalePct: Int = 100
    @State private var showPrint = false
    
    var scale: Double { Double(scalePct) / 100.0 }
    
    init(doc: PDFDocument, printOnce: Bool, dismiss: @escaping () -> Void) {
        self.doc = doc
        self.printOnce = printOnce
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack {
            ScaledPdfView(doc: doc, scale: scale)
            ScalePicker(scalePct: $scalePct)
                .padding(.bottom)
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Print") { showPrint = true }
                Spacer()
            }
        }
        .sheet(isPresented: $showPrint) {
            PrintView(doc: doc, scale: scale, completion: printComplete)
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
        .padding()
    }
    
    func printComplete(completed: Bool) {
        showPrint = false
        if printOnce && completed { dismiss() }
    }
}
