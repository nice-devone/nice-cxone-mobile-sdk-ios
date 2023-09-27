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

enum ThreadListViewState: HasInitial {
    case loading(title: String?)
    case loaded(ThreadListVO)
    case error(title: String, message: String)
    
    static var initial: ThreadListViewState = .loading(title: nil)
}

// MARK: - Queries

extension ThreadListViewState {
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

// MARK: - Commands

extension ThreadListViewState {
    
    mutating func toLoading(title: String? = nil) {
        self = .loading(title: title)
    }
    
    mutating func toLoaded(documentState: ThreadListPresenter.DocumentState) {
        self = .loaded(ThreadListVO(threads: documentState.threads, isMultiThread: documentState.isMultiThread))
    }
    
    mutating func toError(title: String, message: String? = nil) {
        self = .error(title: title, message: message ?? "")
    }
}
