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
import PKCE

class LoginWithAmazonUseCase {
    
    func callAsFunction() async throws {
        guard let authenticator = OAuthenticatorsManager.authenticator else {
            throw CommonError.failed("Unable to get OAuth authenticator.")
        }

        let verifier = try generateCodeVerifier()
        let challenge = try generateCodeChallenge(for: verifier)

        CXoneChat.shared.customer.setCodeVerifier(verifier)

        let (_, result) = try await authenticator.authorize(withChallenge: challenge)
        
        if let result {
            CXoneChat.shared.customer.setAuthorizationCode(result.challengeResult)
        } else {
            throw CommonError.unableToParse("result")
        }
    }
}

// MARK: - Preview Mock

class PreviewLoginWithAmazonUseCase: LoginWithAmazonUseCase {
    
    override func callAsFunction() async throws {
        await Task.sleep(seconds: 2)
    }
}
