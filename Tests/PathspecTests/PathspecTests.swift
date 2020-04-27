//
//  File.swift
//  
//
//  Created by Vincent Esche on 4/23/20.
//

import XCTest
@testable import Pathspec

final class PathspecTests: XCTestCase {
    func testDescription() throws {
        let spec: Pathspec = try XCTUnwrap(["foo", "foo/bar"])

        XCTAssertEqual(
            spec.description,
            """
            <Pathspec specs: [
              <GitIgnoreSpec pattern: "foo">,
              <GitIgnoreSpec pattern: "foo/bar">
            ]>
            """
        )
    }

    func testDebugDescription() throws {
        let spec: Pathspec = try XCTUnwrap(["foo", "foo/bar"])

        XCTAssertEqual(
            spec.debugDescription,
            """
            <Pathspec specs: [
              <GitIgnoreSpec pattern: "foo" regex: "^(?:.+/)?foo(?:/.*)?$">,
              <GitIgnoreSpec pattern: "foo/bar" regex: "^foo/bar(?:/.*)?$">
            ]>
            """
        )
    }
}
