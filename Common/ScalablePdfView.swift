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
    private let dismiss: () -> Void
    @ScaledMetric(relativeTo: .body) private var buttonWidth = 70.0
    @State private var showPrint = false
    
    init(pdf: ScalablePdf, dismiss: @escaping () -> Void) {
        self.pdf = pdf
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack {
            ScaledPdfView(pdf: pdf)
            ScalePicker(scale: $pdf.scale)
            HStack {
                Spacer()
                Button(action: {
                        dismiss()
                 }, label: {
                    Text("Cancel")
                        .frame(width: buttonWidth)
                })
                .buttonStyle(.bordered)
                Button(action: {
                    showPrint = true
                }, label: {
                    Text("Print")
                        .frame(width: buttonWidth)
                })
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showPrint) {
            PrintView(pdf: pdf, dismiss: { showPrint = false })
                .presentationDetents([.medium])
        }
        .padding()
    }
}
