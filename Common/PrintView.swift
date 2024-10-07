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
    private let completion: (Bool) -> Void
    @State private var progressText = "Preparing PDF to print…"
    @State private var scalingTask: Task<Data, Never>? = nil
    @State private var scaledCount = 0.0
    private let pageCount: Double
    
    init(pdf: ScalablePdf, completion: @escaping (Bool) -> Void) {
        self.pdf = pdf
        self.completion = completion
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
                completion(false)
            }
            .padding(.top)
        }
        .padding(40)
        .task {
            await scaleAndPrint()
         }
    }
    
    func scaleAndPrint() async {
        let scalingTask = Task.detached {
            pdf.scalePdf(pageComplete: pageComplete)
        }
        self.scalingTask = scalingTask
        let scaled = await scalingTask.result
        if scalingTask.isCancelled {
            completion(false)
        } else {
            progressText = "Printing PDF…"
            completion(await Self.printData(data: scaled.get()))
        }
    }
    
    nonisolated func pageComplete(pageNumber: Int) {
        Task { @MainActor in
            scaledCount = Double(pageNumber)
        }
    }
    
    static private func printData(data: Data) async -> Bool {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = data
        
        return await withCheckedContinuation { continuation in
            printController.present(animated: true) { _, completed, _ in
                continuation.resume(returning: completed)
            }
        }
    }
}
