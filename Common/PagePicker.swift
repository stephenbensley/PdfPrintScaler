//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI

// A control for selecting the page number to preview.
struct PagePicker: View {
    @ScaledMetric(relativeTo: .body) private var maxWidth = 225.0
    @Binding private var pageNumber: Int
    private let pageCount: Int
    private let firstPage: Int

    init(pageNumber: Binding<Int>, pageCount: Int) {
        self._pageNumber = pageNumber
        self.pageCount = pageCount
        self.firstPage = min(pageCount, 1)
    }

    var body: some View {
        HStack {
            Stepper(
                "Page \(pageNumber) / \(pageCount)",
                value: $pageNumber,
                in: firstPage...pageCount
            )
            .frame(maxWidth: maxWidth)
        }
    }
}

#Preview {
    @Previewable @State var pageNumber = 1
    PagePicker(pageNumber: $pageNumber, pageCount: 10)
}
