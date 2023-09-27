//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {

    // MARK: Properties
    
    @Binding var isVisible: Bool
    @Binding var isTransparent: Bool
    
    var content: () -> Content

    // MARK: - Builder

    var body: some View {
        ZStack(alignment: .center) {
            content()
                .disabled(self.isVisible)
                .blur(radius: self.isVisible ? 10 : 0)
                .opacity(self.isTransparent || !isVisible ? 1 : 0)

            VStack {
                ActivityIndicator(isAnimating: $isVisible, style: .large)
            }
            .opacity(self.isVisible ? 1 : 0)
        }
    }
}

// MARK: - Private Struct

private struct ActivityIndicator: UIViewRepresentable {

    // MARK: - Properties
    
    @Binding var isAnimating: Bool
    
    let style: UIActivityIndicatorView.Style

    // MARK: - Methods
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
