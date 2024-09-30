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
        }
        .onChange(of: doc) { _, _ in
            pageNumber = min(pageCount, 1)
            scale = 100
        }
        .padding()
    }
}

#Preview {
    ScaledPrintView()
}
