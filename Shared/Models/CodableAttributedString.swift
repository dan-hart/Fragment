//
//  CodableAttributedString.swift
//  Fragment
//
//  Created by Dan Hart on 3/28/22.
//

import Foundation

// swiftlint:disable all
public class CodableAttributedString: Codable {
    let value: NSAttributedString

    init(value: NSAttributedString) {
        self.value = value
    }

    public required init(from decoder: Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        guard let attributedString = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(singleContainer.decode(Data.self)) as? NSAttributedString else {
            throw DecodingError.dataCorruptedError(in: singleContainer, debugDescription: "Data is corrupted")
        }
        value = attributedString
    }

    public func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()
        try singleContainer.encode(NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false))
    }
}

// swiftlint:enable all
