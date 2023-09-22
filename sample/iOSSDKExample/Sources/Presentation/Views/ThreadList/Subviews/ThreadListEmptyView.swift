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
