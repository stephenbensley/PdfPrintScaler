//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI

// Displays progress of the scaling operation and presents system print dialog.
struct PrintView: View {
    private let doc: PDFDocument
    private let scale: Double
    private let completion: (Bool) -> Void
    private let pageCount: Double
    @State private var progressText = "Preparing PDF to print…"
    @State private var scalingTask: Task<Data, Never>? = nil
    @State private var scaledCount = 0.0
     
    init(doc: PDFDocument, scale: Double, completion: @escaping (Bool) -> Void) {
        self.doc = doc
        self.scale = scale
        self.completion = completion
        self.pageCount = Double(doc.pageCount)
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
        nonisolated(unsafe) let doc = doc
        let scalingTask = Task.detached { @Sendable in
            doc.scaleBy(scale, pageComplete: pageComplete)
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
