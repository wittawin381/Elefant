//
//  OnboardingFlow.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 2/4/2568 BE.
//

import Foundation
import UIKit
import ElefantAPI
import ElefantEntity
import AuthenticationServices

protocol OnboardingFlowDelegate: AnyObject {
    
}

class OnboardingFlowController: UINavigationController, FlowController {
    var rootNavigationController: UINavigationController { self }
    let appEnvironment: AppEnvironmentDataProvider
    private var authenticationController: AppAuthenticationController
    
    init(authenticationController: AppAuthenticationController = OauthAuthenticationController(),
         appEnvironment: AppEnvironmentDataProvider) {
        let viewController = OnboardingViewController()
        self.authenticationController = authenticationController
        self.appEnvironment = appEnvironment
        
        super.init(rootViewController: viewController)
        
        viewController.delegate = self
        self.authenticationController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OnboardingFlowController: OnboardingViewControllerDelegate {
    func onboardingViewControllerDidTapStartButton(_ viewController: OnboardingViewController) {
        let viewController = ServerPickerViewController()
        viewController.delegate = self
        pushViewController(viewController, animated: true)
    }
}

extension OnboardingFlowController: ServerPickerViewControllerDelegate {
    func serverPickerViewController(_ viewController: ServerPickerViewController, didSelectServer server: ElefantEntity.Server) {
        Task {
            do {
                let credentialApplication = try await registerApp(viewController, with: server)
                try await performLogin(with: server, credentialApplication: credentialApplication)
            } catch {
                showErrorDialog(message: error.localizedDescription)
            }
        }
    }
    
    private func registerApp(_ serverPickerViewController: ServerPickerViewController, with server: Server) async throws -> CredentialApplication {
        let client = ElefantClient(
            session: URLSession.shared,
            server: ElefantClient.Server(domain: server.domain),
            middlewares: MiddlewareGroup(middlewares: [])
        )
        
        return try await ElefantAPI.Apps.RegisterAppV2.default.request(using: client)
    }
}

extension OnboardingFlowController {
    private func performLogin(with server: Server, credentialApplication: ElefantAPI.Apps.RegisterAppV2.Response) async throws {
        let oauthToken = try await authenticationController.performAuthentication(with: server.domain, credentialApplication: credentialApplication)
        await setProfile(domain: server.domain, oauthToken: oauthToken)
    }
    
    private func setProfile(domain: String, oauthToken: Token) async {
        let profile = Profile(
            id: UUID().uuidString,
            domain: domain,
            oauthToken: oauthToken)
        
        let profileController = appEnvironment.profileController
        let isProfileAdded = await profileController.addProfile(profile: profile)
        if isProfileAdded {
            profileController.selectActiveProfile(profileID: profile.id)
        }
    }
    
    private func showErrorDialog(message: String) {
        let alertController = UIAlertController(
            title: "error",
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}

extension OnboardingFlowController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}

extension OnboardingFlowController: OauthAuthenticationControllerDelegate {
    func oauthAuthenticationController(_ authenticationController: OauthAuthenticationController, didErrorWith error: any Error) {
        showErrorDialog(message: error.localizedDescription)
    }
}
