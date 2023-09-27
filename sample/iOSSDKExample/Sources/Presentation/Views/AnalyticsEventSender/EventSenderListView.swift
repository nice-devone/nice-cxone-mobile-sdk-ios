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

import CXoneChatSDK
import SwiftUI

struct EventSenderListView: View {
    
    // MARK: - Properties

    let analyticsProvider: AnalyticsProvider
    let done: () -> Void

    // MARK: - Content

    var body: some View {
        VStack {
            NavigationView {
                List {
                    PageViewSenderView(analyticsProvider: analyticsProvider)
                        .adjustForA11y()
                    ConversionSenderView(analyticsProvider: analyticsProvider)
                        .adjustForA11y()
                }
                .listStyle(.plain)
                .navigationBarTitle("Send Events")
            }
            Spacer()
            Button("Cancel", action: done)
        }
    }
}

// MARK: - Preview

struct EventSenderListView_Previews: PreviewProvider {
    static var previews: some View {
        EventSenderListView(analyticsProvider: PreviewAnalyticsProvider()) {}
    }
}
