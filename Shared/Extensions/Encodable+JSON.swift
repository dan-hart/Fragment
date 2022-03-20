//
//  Encodable+JSON.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

import Foundation

extension JSONEncoder {
    static let shared = JSONEncoder()
    static let iso8601 = JSONEncoder(dateEncodingStrategy: .iso8601)
    static let iso8601PrettyPrinted = JSONEncoder(dateEncodingStrategy: .iso8601, outputFormatting: .prettyPrinted)
}

extension JSONEncoder {
    convenience init(dateEncodingStrategy: DateEncodingStrategy,
                         outputFormatting: OutputFormatting = [],
                      keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys) {
        self.init()
        self.dateEncodingStrategy = dateEncodingStrategy
        self.outputFormatting = outputFormatting
        self.keyEncodingStrategy = keyEncodingStrategy
    }
}

extension Encodable {
    func data(using encoder: JSONEncoder = .iso8601) throws -> Data {
        try encoder.encode(self)
    }
    func dataPrettyPrinted() throws -> Data {
        try JSONEncoder.iso8601PrettyPrinted.encode(self)
    }
    // edit if you need the data using a custom date formatter
    func dataDateFormatted(with dateFormatter: DateFormatter) throws -> Data {
        JSONEncoder.shared.dateEncodingStrategy = .formatted(dateFormatter)
        return try JSONEncoder.shared.encode(self)
    }
    func json() throws -> String {
         String(data: try data(), encoding: .utf8) ?? ""
    }
    func jsonPrettyPrinted() throws -> String {
        String(data: try dataPrettyPrinted(), encoding: .utf8) ?? ""
    }
    func jsonDateFormatted(with dateFormatter: DateFormatter) throws -> String {
        return String(data: try dataDateFormatted(with: dateFormatter), encoding: .utf8) ?? ""
    }
}
