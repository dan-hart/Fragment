//
//  Collections+ifExistsAt.swift
//  Fragment
//
//  Created by Dan Hart on 3/27/22.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(ifExistsAt index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
