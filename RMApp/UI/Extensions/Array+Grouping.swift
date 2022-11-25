//
//  Array+Grouping.swift
//  RMApp
//
//  Created by jorge Sanmartin on 24/11/22.
//

extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}
