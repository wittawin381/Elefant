//
//  OauthMiddleware.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 7/4/2568 BE.
//

import Foundation
import ElefantAPI
import UIKit

struct OauthMiddleware: Middleware {
    let profileController: ProfileController
    
    func respond(to request: URLRequest) async throws -> ResponderEvent<URLRequest> {
        if let accessToken = profileController.activeProfile?.oauthToken.accessToken
        {
            var newRequest = request
            newRequest.allHTTPHeaderFields?["Authorization"] = "Bearer \(accessToken)"
            return .continue(newRequest)
        }
        return .continue(request)
    }
}
