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
struct ScaledDocView: View {
    // Document begin viewed.
    private let doc: PDFDocument
    // Current scale factor.
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
                        ScaledPageView(page: page, scale: scale, maxSize: proxy.size)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    ScaledDocView(doc: Sample.doc, scale: 1.0)
}
