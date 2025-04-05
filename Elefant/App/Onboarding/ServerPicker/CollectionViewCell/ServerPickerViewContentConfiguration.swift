//
//  ServerPickerViewContentConfiguration.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 3/4/2568 BE.
//

import Foundation
import UIKit

struct ServerPickerViewContentConfiguration: UIContentConfiguration, Hashable {
    let serverName: String
    let description: String
    let coverImageURL: String?
    let totalUsers: Int
    let lastWeekUser: Int
    
    func makeContentView() -> any UIView & UIContentView {
        ServerPickerItemView(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> Self {
        self
    }
}
