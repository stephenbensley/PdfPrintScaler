//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI

// Main view for operating on a PDF after it has been loaded.
struct ProcessPdfView: View {
    // Document being processed.
    private let doc: PDFDocument
    // True if the user is only allowed to print the document once before.
    private let printOnce: Bool
    // Used to dismiss the view.
    private let dismiss: () -> Void
    // Current scale percentage.
    @State var scalePct: Int = 100
    // Trigger the print dialog.
    @State private var showPrint = false
    
    // Converts scale percentage to a 1.0-based scale factor.
    var scale: Double { Double(scalePct) / 100.0 }
    
    init(doc: PDFDocument, printOnce: Bool, dismiss: @escaping () -> Void) {
        self.doc = doc
        self.printOnce = printOnce
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack {
            ScaledDocView(doc: doc, scale: scale)
                .padding(.bottom)
           ScalePicker(scalePct: $scalePct)
                .padding(.bottom)
            HStack {
                Spacer()
                Spacer()
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Print") { showPrint = true }
                Spacer()
                Spacer()
            }
        }
        .sheet(isPresented: $showPrint) {
            ScaleAndPrintView(doc: doc, scale: scale, completion: printComplete)
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

#Preview {
    ProcessPdfView(doc: Sample.doc, printOnce: false, dismiss: { })
}
