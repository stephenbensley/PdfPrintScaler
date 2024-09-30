//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/PdfPrintScaler/blob/main/LICENSE.
//

import SwiftUI

// Presents a scaled image. Scaled is not the same as resized. The original image dimensions are
// preserved. If scaleFactor > 1.0, some of the image will be cropped. If scaleFactor < 1.0,
// whitespace will be added.
struct ScaledImage: View {
    private let image: UIImage
    private let scaleFactor: CGFloat
    
    init(image: UIImage, scaleFactor: CGFloat) {
        self.image = image
        self.scaleFactor = scaleFactor
    }

    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .frame(size: proxy.size.scaled(by: scaleFactor))
                .frame(size: proxy.size)
                .clipped()
                .border(Color.red)
        }
        .aspectRatio(image.size.aspectRatio, contentMode: .fit)
    }
}

#Preview {
    ScaledImage(image: UIImage(named: "UnknownPage")!, scaleFactor: 1.0)
}
