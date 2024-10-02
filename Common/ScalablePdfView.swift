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
    @State private var showProgress = false
    
    init(pdf: ScalablePdf, dismiss: @escaping () -> Void) {
        self.pdf = pdf
        self.dismiss = dismiss
    }
    
    var body: some View {
        VStack {
            ScaledImage(image: pdf.preview, scaleFactor: pdf.scaleFactor)
            PagePicker(pageNumber: $pdf.pageNumber, pageCount: pdf.pageCount)
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
                    Task { [pdf] in
                        showProgress = true
                        let scaled = await pdf.scalePdf()
                        await Self.printData(data: scaled)
                        showProgress = false
                    }
                }, label: {
                    Text("Print")
                        .frame(width: buttonWidth)
                })
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showProgress) {
            ProgressView("Preparing PDF to print…")
                .presentationDetents([.medium])
        }
        .padding()
    }
    
    static private func printData(data: Data) async {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = data
        
        await withCheckedContinuation { continuation in
            printController.present(animated: true) { _, _, _ in
                continuation.resume()
            }
        }
    }
}
