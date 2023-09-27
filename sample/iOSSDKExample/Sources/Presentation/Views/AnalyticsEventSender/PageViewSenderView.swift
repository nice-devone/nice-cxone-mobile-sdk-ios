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

struct PageViewSenderView: View {
    
    // MARK: - Properties

    let analyticsProvider: AnalyticsProvider
    @State var title: String = ""
    @State var url: String = ""

    // MARK: - Content

    var body: some View {
        EventSenderView(label: "Page View") {
            Task {
                do {
                    try await analyticsProvider.viewPage(title: title, url: url)
                } catch {
                    error.logError()
                }
            }
        } enabled: {
            !title.isEmpty && !url.isEmpty
        } content: {
            ValidatedTextField("Title", text: $title, validator: required)
            
            ValidatedTextField("URL", text: $url, validator: required)
        }
    }
}
