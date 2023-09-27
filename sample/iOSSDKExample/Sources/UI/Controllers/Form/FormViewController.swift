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

import CXoneChatSDK
import UIKit

class FormViewController: BaseViewController {
    
    // MARK: - Views
    
    let myView = FormView()
    
    // MARK: - Properties

    private let viewObject: FormVO
    
    private let onFinished: ([String: String]) -> Void
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(entity: FormVO, onFinished: @escaping ([String: String]) -> Void) {
        self.viewObject = entity
        self.onFinished = onFinished
        super.init(nibName: nil, bundle: nil)
        
        myView.titleLabel.text = entity.title
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myView.setupView(with: viewObject)
    }
    
    override func loadView() {
        super.loadView()
        
        view = myView
        
        myView.confirmButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        myView.cancelButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

private extension FormViewController {
    
    @objc
    func onButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        switch sender {
        case myView.cancelButton:
            dismiss(animated: true)
        case myView.confirmButton:
            guard myView.areFieldsValid() else {
                Log.error(CommonError.failed("Form values are not valid."))
                return
            }
            
            dismiss(animated: true) {
                self.onFinished(self.myView.customFields)
            }
        default:
            Log.error(CommonError.failed("Unknown sender did tap."))
        }
    }
}
