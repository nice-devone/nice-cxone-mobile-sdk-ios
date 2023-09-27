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
import WebKit

class WKWebViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Views
    
    let webView = WKWebView()
    let toolbar = UIToolbar()
    let goForward = UIBarButtonItem()
    
    // MARK: - Properties
    
    let url: URL
    var observerValue: NSKeyValueObservation?
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAllSubviews()
        setupSubviews()
        setupConstraints()
    }
}

// MARK: - Actions

extension WKWebViewController {
    
    @objc
    func closeDidTap() {
        dismiss(animated: true)
    }
    
    @objc
    func goesBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    func onForwardButtonPressed() {
        guard webView.canGoForward else {
            Log.error("Unable to go forward.")
            return
        }
        
        webView.goForward()
    }
    
    @objc
    func shareLink() {
        guard let url = webView.url else {
            Log.error(CommonError.unableToParse("url", from: webView))
            return
        }
        
        self.present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
    }
    
    @objc
    func openInBrowser() {
        guard let url = webView.url else {
            Log.error(CommonError.unableToParse("url", from: webView))
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            Log.error("Unable to open url - \(url)")
            return
        }
        
        UIApplication.shared.open(url)
    }
}

// MARK: - Private methods

private extension WKWebViewController {
    
    func addAllSubviews() {
        view.addSubviews(webView, toolbar)
    }
    
    func setupSubviews() {
        title = webView.url?.baseURL?.description ?? ""
        
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: L10n.Common.close, style: .done, target: self, action: #selector(closeDidTap))
        
        toolbar.backgroundColor = .systemBackground
        toolbar.items = [
            UIBarButtonItem(image: Asset.Common.back, style: .plain, target: self, action: #selector(goesBack)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: Asset.Common.share, style: .plain, target: self, action: #selector(shareLink)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: Asset.Common.safari, style: .plain, target: self, action: #selector(openInBrowser))
        ]
        
        observerValue = webView.observe(\.title) { [weak navigationItem] webView, _ in
            DispatchQueue.main.async {
                navigationItem?.title = webView.title
            }
        }
    }
    
    func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        toolbar.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
