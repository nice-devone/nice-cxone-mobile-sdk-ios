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

class ThreadListView: BaseView {
    
    // MARK: - Views
    
    let segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: L10n.ThreadList.SegmentControl.availableThreads, at: 0, animated: false)
        view.insertSegment(withTitle: L10n.ThreadList.SegmentControl.archivedThreads, at: 1, animated: false)
        view.selectedSegmentIndex = 0
        
        return view
    }()
    private let headerView = UIView()
    private let separator = UIView()
    
    let emptyView = ThreadListEmptyView()
    let tableView = UITableView()
    
    // MARK: - Init

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)

        addAllSubviews()
        setupConstraints()
        setupColors()
    }
    
    // MARK: - Lifecycle
    
    override func setupColors() {
        backgroundColor = .systemBackground
        
        separator.backgroundColor = .separator
    }
}

// MARK: - Private methods

private extension ThreadListView {
    
    func addAllSubviews() {
        addSubviews(emptyView, headerView, tableView)
        
        headerView.addSubviews(segmentedControl, separator)
    }
    
    func setupConstraints() {
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(32)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
            make.height.equalTo(0.5)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
