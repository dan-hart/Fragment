//
//  TestApp.swift
//  Fragment
//
//  Created by Dan Hart on 3/20/22.
//

@testable import Fragment
import XCTest

class TestApp: XCTestCase {
    static func appTest() {
        let app = FragmentApp()
        XCTAssertNotNil(app)
    }
}
