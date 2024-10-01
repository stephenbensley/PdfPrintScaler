//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI

// Main view for the Scaled Print functionality -- shared between the app and the extension.
struct ScaledPrintView: View {
    @State private var doc: PDFDocument? = nil
    @State private var pageNumber = 0
    @State private var scale: Int = 100
    @ScaledMetric(relativeTo: .body) private var buttonWidth = 70.0
    @State private var showProgress = false
    private let unknownPage = UIImage(named: "UnknownPage") ?? UIImage()
    
    var currentPage: UIImage {
        doc?.page(at: pageNumber - 1)?.uiImage(dpi: 150.0) ?? unknownPage
    }
    var pageCount: Int { doc?.pageCount ?? 0 }
    var scaleFactor: CGFloat { CGFloat(scale)/100.0 }
    
    var body: some View {
        VStack {
            if doc == nil {
                PdfFilePicker(doc: $doc)
            } else {
                ScaledImage(image: currentPage, scaleFactor: scaleFactor)
            }
            PagePicker(pageNumber: $pageNumber, pageCount: pageCount)
            ScalePicker(scale: $scale)
            HStack {
                Spacer()
                Button(action: {
                    doc = nil
                }, label: {
                    Text("Cancel")
                        .frame(width: buttonWidth)
                })
                .buttonStyle(.bordered)
                Button(action: {
                    Task {
                        showProgress = true
                        if let data = await scalePdf() {
                            await printPdf(data: data)
                        }
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
        .onChange(of: doc) { _, _ in
            pageNumber = min(pageCount, 1)
            scale = 100
        }
        .padding()
    }
    
    private func printPdf(data: Data) async {
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
    
    private func scalePdf() async -> Data? {
        guard let data = doc?.dataRepresentation() else { return nil }
        // Must be detached to avoid hogging MainActor
        let task = Task.detached {
            await PDFDocument(data: data)?.scaleBy(scaleFactor)
        }
        return await task.result.get()
    }
    
}

#Preview {
    ScaledPrintView()
}
