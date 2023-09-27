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

extension UINavigationController {
    
    func setNormalNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = nil
        appearance.shadowImage = nil
        
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = .systemBlue
        navigationBar.barTintColor = .systemBackground
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setCustomNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ChatAppearance.navigationBarColor
        appearance.shadowColor = nil
        appearance.shadowImage = nil
        appearance.titleTextAttributes = [.foregroundColor: ChatAppearance.navigationElementsColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: ChatAppearance.navigationElementsColor]
        
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = ChatAppearance.navigationElementsColor
        navigationBar.barTintColor = ChatAppearance.navigationBarColor
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}
