//
//  SessionManager.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 3/4/2568 BE.
//

import Foundation
import ElefantAPI

private let kDefaultProfileIDKey = "elefant_default_profile_id_key"

@MainActor protocol ProfileControllerDelegate: AnyObject {
    func profileController(_ profileController: ProfileController, didSelectActiveProfile profile: Profile)
    func profileControllerDidFailToSelectActiveProfile(_ profileController: ProfileController)
}

@MainActor class ProfileController {
    weak var delegate: ProfileControllerDelegate?
    private let keychain: Keychain
    private let userDefaults: UserDefaults
    
    var activeProfile: Profile? {
        didSet {
            if let activeProfile {
                delegate?.profileController(self, didSelectActiveProfile: activeProfile)
            } else {
                delegate?.profileControllerDidFailToSelectActiveProfile(self)
            }
        }
    }
    private var profiles: [Profile] = []
    
    init(keychain: Keychain, userDefaults: UserDefaults) {
        self.keychain = keychain
        self.userDefaults = userDefaults
    }
    
    func loadProfile() async {
        let defaultsProfileKeyFromUserDefaults = userDefaults.string(forKey: kDefaultProfileIDKey)
        let allProfiles = await Profile.all(from: keychain)
        profiles = allProfiles
        
        if allProfiles.isEmpty {
            await keychain.removeAll()
            activeProfile = nil
            return
        }
        
        if let defaultsProfileKeyFromUserDefaults, let profileFromDefaultValue = allProfiles.first(where: { $0.id == defaultsProfileKeyFromUserDefaults }) {
            activeProfile = profileFromDefaultValue
        } else if let firstProfile = allProfiles.first {
            activeProfile = firstProfile
        }
    }
    
    func addProfile(profile: Profile) async -> Bool {
        profiles.append(profile)
        return await profile.save(to: keychain)
    }
    
    func selectActiveProfile(profileID: String) {
        guard let profile = profiles.first(where: { $0.id == profileID }) else { return }
        userDefaults.set(profile.id, forKey: kDefaultProfileIDKey)
        activeProfile = profile
    }
    
    func removeProfile(profileID: String) async {
        let isProfileDeleted = await Profile.removeProfile(with: profileID, from: keychain)
        guard isProfileDeleted else { return }
        profiles.removeAll(where: { $0.id == profileID })
        if let activeProfile, activeProfile.id == profileID {
            self.activeProfile = nil
            userDefaults.removeObject(forKey: kDefaultProfileIDKey)
        }
    }
}
