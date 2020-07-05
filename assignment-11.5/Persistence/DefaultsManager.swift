//
//  DefaultsManager.swift
//  assignment-11.5
//
//  Created by Mughees Mustafa on 04/07/2020.
//  Copyright © 2020 Mughees Mustafa. All rights reserved.
//

import Foundation
class DefaultsManager {
    private init () {}
    static let shared = DefaultsManager()
    let defaultsKeyArray = "suggestions"
    let defaults = UserDefaults.standard
    
    func getSuggestions()-> [String]? {
        return defaults.stringArray(forKey: defaultsKeyArray)
    }
    
    func addSuggestion(text: String) {
        if var array = defaults.stringArray(forKey: defaultsKeyArray) {
            if array.count == 10 {
                array.removeFirst()
            }
            array.append(text)
            defaults.set(array, forKey: defaultsKeyArray)
        } else {
            let newArray = [text]
            defaults.set(newArray, forKey: defaultsKeyArray)
        }
    }
}
