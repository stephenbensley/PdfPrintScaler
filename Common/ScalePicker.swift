//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI

// A control for selecting the scale factor.
struct ScalePicker: View {
    @ScaledMetric(relativeTo: .body) private var maxWidth = 50.0
    @Binding private var scale: Int
    
    init(scale: Binding<Int>) {
        self._scale = scale
     }
    
    var body: some View {
        HStack {
            Text("Scale:")
            TextField("Scale", value: $scale, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: maxWidth)
            Text("%")
                .padding(.trailing)
            Stepper("Scale", onIncrement: {
                    scale += 1
                }, onDecrement: {
                    if scale > 0 { scale -= 1}
                })
            .labelsHidden()
        }
        .onChange(of: scale) {
            if scale < 1 { scale = 1 }
        }
    }
}

#Preview {
    @Previewable @State var scale = 100
    ScalePicker(scale: $scale)
}
