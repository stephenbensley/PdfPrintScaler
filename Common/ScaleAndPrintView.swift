//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI

// Displays progress of the scaling operation and presents the system print dialog.
struct ScaleAndPrintView: View {
    private let doc: PDFDocument
    private let scale: Double
    // Invoked when the operation is complete. The Bool parameter indicates whether or not a print
    // job was successfully submitted.
    private let completion: (Bool) -> Void
    private let pageCount: Double
    @State private var progressText = "Preparing PDF to print…"
    // Detached task used to scale the Pdf.
    @State private var scaleTask: Task<Data, Never>? = nil
    // Number of pages scaled so far.
    @State private var scaledCount = 0.0
     
    init(doc: PDFDocument, scale: Double, completion: @escaping (Bool) -> Void) {
        self.doc = doc
        self.scale = scale
        self.completion = completion
        self.pageCount = Double(doc.pageCount)
    }
    
    var body: some View {
        VStack {
            // For small docs, indeterminate progress looks better.
            if pageCount < 5 {
                ProgressView(progressText)
            } else {
                ProgressView(progressText, value: scaledCount, total: pageCount)
            }
            Button("Cancel") {
                scaleTask?.cancel()
                completion(false)
            }
            .padding(.top)
        }
        .task {
            await scaleAndPrint()
         }
    }
    
    func scaleAndPrint() async {
        // PDFDocument isn't Sendable, but we're only accessing read-only properties and functions.
        nonisolated(unsafe) let doc = doc
        // Must use a detached Task to avoid hogging MainActor.
        let scalingTask = Task.detached { @Sendable in
            doc.scaleBy(scale, pageComplete: pageComplete)
        }
        // Store the task, so the cancel button can find it.
        self.scaleTask = scalingTask
        // Now we can wait for the result.
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

#Preview {
    ScaleAndPrintView(doc: Sample.doc, scale: 1.0, completion: { _ in })
}
