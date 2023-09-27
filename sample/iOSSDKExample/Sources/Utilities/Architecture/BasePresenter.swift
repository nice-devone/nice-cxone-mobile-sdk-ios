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

open class BasePresenter<TInput, TNavigation, TServices, TViewState: HasInitial>: NSObject {

    // MARK: - ViewState

    public var viewState = TViewState.initial {
        didSet { onViewStateChanged(viewState) }
    }
    private var onViewStateChanged: (TViewState) -> Void = { _ in }

    // MARK: - Private properties

    public let input: TInput
    public let navigation: TNavigation
    public let services: TServices

    // MARK: - Init

    public required init(input: TInput, navigation: TNavigation, services: TServices) {
        self.input = input
        self.navigation = navigation
        self.services = services
    }

    public func subscribe<T: ViewRenderable>(from view: T) where T.ViewState == TViewState {
        onViewStateChanged = { [weak view] viewState in
            if let view = view {
                if Thread.isMainThread {
                    view.render(state: viewState)
                } else {
                    DispatchQueue.main.async {
                        view.render(state: viewState)
                    }
                }
            }
        }
        view.render(state: viewState)

        viewDidSubscribe()
    }

    /// When renderable view is subscribed, this method is called.
    open func viewDidSubscribe() { }
}
