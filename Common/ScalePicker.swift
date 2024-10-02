//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI

// A control for selecting the scale factor.
struct ScalePicker: View {
    @ScaledMetric(relativeTo: .body) private var maxWidth = 225.0
    @Binding private var scale: Int

    init(scale: Binding<Int>) {
        self._scale = scale
    }

    var body: some View {
        HStack {
            Stepper(
                "Scale \(scale)",
                value: $scale,
                in: 1...500
            )
            .frame(maxWidth: maxWidth)
        }
    }
}

#Preview {
    @Previewable @State var scale = 100
    ScalePicker(scale: $scale)
}
