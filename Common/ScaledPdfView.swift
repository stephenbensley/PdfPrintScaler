//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI
import UtiliKit

// Presents a preview of the scaled document. Scaled is not the same as resized. The original page
// dimensions are preserved. If scaleFactor > 1.0, some of the page will be cropped. If
// scaleFactor < 1.0, whitespace will be added.
struct ScaledPdfView: View {
    private let doc: PDFDocument
    private let scale: Double
 
    init(doc: PDFDocument, scale: Double) {
        self.doc = doc
        self.scale = scale
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(doc, id: \.self) { page in
                        // Render the page in lower res for preview
                        let image = page.uiImage(dpi: 100.0)
                        // Aspect ratio must be preserved.
                        let aspectRatio = image.size.aspectRatio
                        // Make page preview as large as possible.
                        let pageFrame = proxy.size.shrinkToAspectRatio(aspectRatio)
                        // Scale the page content relative to the page frame.
                        let contentFrame = pageFrame.scaled(by: scale)
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(size: contentFrame)
                            .frame(size: pageFrame)
                            .background(.white)
                            .clipped()
                            .border(Color.red)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    ScaledPdfView(doc: Sample.doc, scale: 1.0)
}
