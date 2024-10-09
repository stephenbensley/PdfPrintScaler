//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import PDFKit
import SwiftUI

// Presents a preview of a scaled page.
struct ScaledPageView: View {
    private let page: PDFPage
    private let scale: Double
    private let pageFrame: CGSize
    private let contentFrame: CGSize
    @State private var image: UIImage? = nil
    
    init(page: PDFPage, scale: Double, maxSize: CGSize) {
        self.page = page
        self.scale = scale
        let aspectRatio = page.bounds(for: .mediaBox).size.aspectRatio
        self.pageFrame = maxSize.shrinkToAspectRatio(aspectRatio)
        self.contentFrame = pageFrame.scaled(by: scale)
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .frame(size: contentFrame)
        .frame(size: pageFrame)
        .background(.white)
        .clipped()
        .border(Color.red)
        .onAppear {
            convertPage()
        }
    }
    
    func convertPage() {
        // PDFPage isn't Sendable, but we're only accessing read-only properties and functions.
        nonisolated(unsafe) let page = page
        Task.detached { @Sendable in
            // Use lower dpi for previews.
            let image = page.uiImage(dpi: 100.0)
            await MainActor.run {
                self.image = image
            }
        }
    }
}

#Preview {
    ScaledPageView(
        page: Sample.doc.page(at: 0)!,
        scale: 1.0,
        maxSize: .init(width: 300.0, height: 500.0)
    )
}

