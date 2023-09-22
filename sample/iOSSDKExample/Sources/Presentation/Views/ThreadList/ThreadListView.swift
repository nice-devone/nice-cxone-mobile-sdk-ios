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