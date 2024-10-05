//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI

// Displays progress of the scaling operation and presents system print dialog.
struct PrintView: View {
    private nonisolated(unsafe) var pdf: ScalablePdf
    private let dismiss: () -> Void
    @State private var progressText = "Preparing PDF to print…"
    @State private var scalingTask: Task<Data, Never>? = nil
    @State private var scaledCount = 0.0
    private let pageCount: Double
    
    init(pdf: ScalablePdf, dismiss: @escaping () -> Void) {
        self.pdf = pdf
        self.dismiss = dismiss
        self.pageCount = Double(pdf.pageCount)
    }
    
    var body: some View {
        VStack {
            if pageCount < 5 {
                ProgressView(progressText)
            } else {
                ProgressView(progressText, value: scaledCount, total: pageCount)
            }
            Button("Cancel") {
                scalingTask?.cancel()
                dismiss()
            }
            .padding(.top)
        }
        .padding(40)
        .task {
            let scalingTask = Task.detached {
                pdf.scalePdf(pageComplete: pageComplete)
            }
            self.scalingTask = scalingTask
            let scaled = await scalingTask.result
            if !scalingTask.isCancelled {
                progressText = "Printing PDF…"
                await Self.printData(data: scaled.get())
            }
            dismiss()
        }
    }
    
    nonisolated func pageComplete(pageNumber: Int) {
        Task { @MainActor in
            scaledCount = Double(pageNumber)
        }
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
