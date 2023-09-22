import CXoneChatSDK
import SafariServices
import UIKit

class ProActiveActionPopup: UIView {
    
    // MARK: - Properties
    
    private var timer: Timer?
    private var timerFired = false
    
    private let data: [String: Any]
    private let actionId: UUID
    private let actionDetails: ProactiveActionDetails
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(data: [String: Any], actionId: UUID) {
        self.data = data
        self.actionId = actionId
        self.actionDetails = ProactiveActionDetails(
            id: actionId,
            name: "Custom Popup Box",
            type: .customPopupBox,
            content: ProactiveActionDataMessageContent(
                bodyText: data["bodyText"] as? String,
                headlineText: data["headingText"] as? String
            )
        )
        super.init(frame: .zero)
        
        setup()
    }
}

// MARK: - Actions

private extension ProActiveActionPopup {
    
    @objc
    func fireTimer() {
        timerFired = true
        
        Task {
            do {
                try await CXoneChat.shared.analytics.proactiveActionSuccess(true, data: actionDetails)
            } catch {
                error.logError()
            }
        }
    }
    
    @objc
    func closeDidTap(_ sender: UIButton) {
        isHidden = true
        
        if !timerFired {
            Task {
                do {
                    try await CXoneChat.shared.analytics.proactiveActionSuccess(false, data: actionDetails)
                } catch {
                    error.logError()
                }
            }
        }
    }
    
    @objc
    func buttonTapped() {
        guard let action = data["action"] as? [String: String], let urlString = action["url"], let url = URL(string: urlString) else {
            return
        }
        
        UIApplication.shared.currentController?.present(SFSafariViewController(url: url), animated: true)
        
        Task {
            do {
                try await CXoneChat.shared.analytics.proactiveActionClick(data: self.actionDetails)
                try await CXoneChat.shared.analytics.proactiveActionSuccess(true, data: self.actionDetails)
            } catch {
                error.logError()
            }
        }
        
        self.timer?.invalidate()
    }
}

// MARK: - Private methods

private extension ProActiveActionPopup {

    func setup() {
        layer.cornerRadius = 18
        
        let label = UILabel(frame: .zero)
        label.text = data["headingText"] as? String
        label.font = .preferredFont(forTextStyle: .title3, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(18)
        }
        
        let headeLineLabel = UILabel(frame: .zero)
        headeLineLabel.text = data["bodyText"] as? String
        headeLineLabel.numberOfLines = 0
        headeLineLabel.lineBreakMode = .byWordWrapping
        addSubview(headeLineLabel)
        
        headeLineLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        
        let closeButton = UIButton(type: .close)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeDidTap), for: .touchUpInside)
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
        }
        
        let action = data["action"] as? [String: String]
        
        let button = PrimaryButton()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setTitle(action?["text"], for: .normal)
        addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalTo(headeLineLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(18)
        }
        
        Task {
            do {
                try await CXoneChat.shared.analytics.proactiveActionDisplay(data: actionDetails)
            } catch {
                error.logError()
            }
        }
        
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
}
