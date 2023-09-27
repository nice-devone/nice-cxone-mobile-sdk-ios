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
import UIKit

extension UIViewController {
        
    func showAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: L10n.Common.ok, style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true) 
    }
    
    func showLoading(title: String? = nil) {
        LegacyLoadingView.shared.startAnimating(with: title)
    }
    
    func hideLoading() {
        LegacyLoadingView.shared.stopAnimatimating()
    }
}

// MARK: - Loading View

private class LegacyLoadingView {

    // MARK: - Variables
    
    private let containerView = UIView()
    private let blurView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private let titleLabel = UILabel()

    static var shared = LegacyLoadingView()

    // MARK: - Private Init
    
    private init() { }

    // MARK: - Functions
    
    func startAnimating(with title: String? = nil) {
        guard !activityIndicator.isAnimating else {
            return
        }
        guard let view = UIApplication.shared.mainWindow?.rootViewController?.view else {
            Log.error(.unableToParse("mainWindow"))
            return
        }
        
        view.addSubview(containerView)
        containerView.addSubviews(blurView, activityIndicator, titleLabel)
        
        containerView.alpha = 0
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.style = .large
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(activityIndicator.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurEffectView)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.containerView.alpha = 1
            }
        }
    }

    func stopAnimatimating() {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.2,
                animations: { [weak self] in
                    self?.containerView.alpha = 0
                },
                completion: { [weak self] _ in
                    self?.activityIndicator.stopAnimating()
                    self?.containerView.removeFromSuperview()
                }
            )
        }
    }
}
