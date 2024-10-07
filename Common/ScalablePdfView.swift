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
    @Bindable private var pdf: ScalablePdf
    private let printOnce: Bool
    private let dismiss: () -> Void
    @State private var showPrint = false
    
    init(pdf: ScalablePdf, printOnce: Bool, dismiss: @escaping () -> Void) {
        self.pdf = pdf
        self.printOnce = printOnce
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack {
            ScaledPdfView(pdf: pdf)
            ScalePicker(scale: $pdf.scale)
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
            PrintView(pdf: pdf, completion: printComplete)
                .presentationDetents([.medium])
        }
        .padding()
    }
    
    func printComplete(completed: Bool) {
        showPrint = false
        if printOnce && completed { dismiss() }
    }
}
