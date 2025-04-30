//
//  OauthAuthenticationController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 4/4/2568 BE.
//

import Foundation
import ElefantAPI
import ElefantEntity
import AuthenticationServices

protocol OauthAuthenticationControllerDelegate: ASWebAuthenticationPresentationContextProviding {
    func oauthAuthenticationController(_ authenticationController: OauthAuthenticationController, didErrorWith error: Error)
}

@MainActor protocol AppAuthenticationController {
    var delegate: OauthAuthenticationControllerDelegate? { get set }
    
    func performAuthentication(with domain: String, credentialApplication: CredentialApplication) async throws -> Token
}

@MainActor class OauthAuthenticationController: AppAuthenticationController {
    weak var delegate: OauthAuthenticationControllerDelegate?
    
    enum OauthAuthenticationControllerError: Error {
        case invalidRequestURL
        case invalidResponseURL
    }
    
    func performAuthentication(with domain: String, credentialApplication: CredentialApplication) async throws -> Token {
        let clientID = credentialApplication.clientID
        let clientSecret = credentialApplication.clientSecret
        let redirectURI = credentialApplication.redirectURI

        let signInURL = try await oauthAuthorize(
            with: domain,
            clientID: clientID,
            clientSecret: clientSecret,
            redirectURI: redirectURI)
        
        return try await oauthToken(
            with: signInURL,
            domain: domain,
            clientID: clientID,
            clientSecret: clientSecret)
    }
    
    private func oauthAuthorize(with domain: String, clientID: String, clientSecret: String, redirectURI: String) async throws -> URL {
        let url = ElefantAPI.OAuth.AuthorizeV2(clientID: clientID, redirectURI: redirectURI).createRequestURL(domain: domain)
        guard let url else {
            throw OauthAuthenticationControllerError.invalidRequestURL
        }
        return await withCheckedContinuation { continuation in
            let authenticationSession = ASWebAuthenticationSession(
                url: url ,
                callback: ASWebAuthenticationSession.Callback.customScheme(AppInfo.appScheme.replacingOccurrences(of: "://", with: ""))) { url, error in
                    guard let url else { return }
                    continuation.resume(returning: url)
                }
            authenticationSession.presentationContextProvider = delegate
            authenticationSession.start()
        }
    }
    
    private func oauthToken(with url: URL, domain: String, clientID: String, clientSecret: String) async throws -> ElefantAPI.OAuth.OAuthTokenV2.Response {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard let code = urlComponents?.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw OauthAuthenticationControllerError.invalidResponseURL
        }
        let client = ElefantClient(
            session: URLSession.shared,
            server: ElefantClient.Server(domain: domain),
            middlewares: .init(middlewares: []))
        
        return try await ElefantAPI.OAuth.OAuthTokenV2(code: code, clientID: clientID, clientSecret: clientSecret).request(using: client)
    }
}
