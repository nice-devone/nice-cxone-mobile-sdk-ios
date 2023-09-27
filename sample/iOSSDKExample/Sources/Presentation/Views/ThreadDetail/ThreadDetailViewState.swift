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

import Foundation

enum ThreadDetailViewState: HasInitial {
    case loading(title: String?)
    case loaded(ThreadDetailVO)
    case refreshSection(index: Int, addingNewItem: Bool)
    case error(title: String, message: String)
    
    static var initial: ThreadDetailViewState = .loading(title: nil)
}

// MARK: - Queries

extension ThreadDetailViewState {
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

// MARK: - Commands

extension ThreadDetailViewState {
    
    mutating func toLoading(title: String? = nil) {
        self = .loading(title: title)
    }
    
    mutating func toLoaded(documentState: ThreadDetailPresenter.DocumentState) {
        self = .loaded(
            ThreadDetailVO(
                title: documentState.title,
                isAgentTyping: documentState.isAgentTyping,
                isEditButtonHidden: documentState.isEditButtonHidden,
                shouldReloadData: documentState.shouldReloadData,
                brandLogo: documentState.brandLogo
            )
        )
    }
    
    mutating func toRefreshSection(index: Int, addingNewItem: Bool) {
        self = .refreshSection(index: index, addingNewItem: addingNewItem)
    }
    
    mutating func toError(title: String, message: String? = nil) {
        self = .error(title: title, message: message ?? "")
    }
}
