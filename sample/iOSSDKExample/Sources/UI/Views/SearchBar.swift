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

struct SearchBar: View {

    // MARK: - Properties
    
    @Binding var text: String
    
    // MARK: - Builder
    
    var body: some View {
        HStack(spacing: 16) {
            HStack {
                Asset.Store.search
                    .foregroundColor(Color(.systemGray2))
                
                TextField(L10n.Common.search, text: $text)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                if !text.isEmpty {
                    Asset.Common.clear
                        .imageScale(.medium)
                        .foregroundColor(Color(.systemGray2))
                        .onTapGesture {
                            withAnimation {
                                self.text = ""
                            }
                        }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
            .animation(.spring(), value: text)
            
            if !text.isEmpty {
                Button(L10n.Common.cancel) {
                    withAnimation {
                        self.text = ""
                    }
                    
                    self.hideKeyboard()
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview

struct SearchBar_Previews: PreviewProvider {
    
    @State private static var searchText = ""
    
    static var previews: some View {
        Group {
            SearchBar(text: $searchText)
                .previewDisplayName("Light Mode")
            
            SearchBar(text: $searchText)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
