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

import UIKit

class ThreadListEmptyView: BaseView {
    
    // MARK: - Views
    
    private let titleLabel = UILabel()
    
    // MARK: - Init

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)

        addAllSubviews()
        setupSubviews()
        setupConstraints()
        setupColors()
    }
    
    // MARK: - Lifecycle
    
    override func setupColors() {
        backgroundColor = .systemBackground
        titleLabel.textColor = .darkGray
    }
}

// MARK: - Private methods

private extension ThreadListEmptyView {
    
    func addAllSubviews() {
        addSubview(titleLabel)
    }

    func setupSubviews() {
        titleLabel.text = L10n.ThreadList.emptyTitle
        titleLabel.font = .preferredFont(forTextStyle: .title3)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
