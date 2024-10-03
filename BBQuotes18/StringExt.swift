//
//  StringExt.swift
//  BBQuotes18
//
//  Created by Tomáš Dušek on 05.10.2024.
//

import Foundation

extension String {
   func removeSpaces() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
    
    func removeCaseAndSpace() -> String {
        self.removeSpaces().lowercased()
    }
}
