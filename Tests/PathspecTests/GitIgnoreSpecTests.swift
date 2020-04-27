//
//  PathspecTests.swift
//  Pathspec
//
//  Created by Geoffrey Foster on 2019-06-29.
//

import XCTest
@testable import Pathspec

final class GitIgnoreSpecTests: XCTestCase {
	func testDescription() throws {
        let spec = try XCTUnwrap(GitIgnoreSpec(pattern: "foobar"))

        XCTAssertEqual(spec.description, "<GitIgnoreSpec pattern: \"foobar\">")
    }

    func testDebugDescription() throws {
        let spec = try XCTUnwrap(GitIgnoreSpec(pattern: "foobar"))

        XCTAssertEqual(spec.debugDescription, "<GitIgnoreSpec pattern: \"foobar\" regex: \"^(?:.+/)?foobar(?:/.*)?$\">")
    }

    func testAbsoluteRoot() throws {
		XCTAssertThrowsError(try GitIgnoreSpec(pattern: "/"))
	}
	
	func testComment() throws {
        XCTAssertThrowsError(try GitIgnoreSpec(pattern: "# Cork soakers."))
	}
	
	func testIgnore() throws {
		let spec = try XCTUnwrap(GitIgnoreSpec(pattern: "!temp"))
		XCTAssertFalse(spec.inclusive)
		XCTAssertEqual(spec.regex.pattern, "^(?:.+/)?temp$")
		let result = spec.match(file: "temp/foo")
		XCTAssertEqual(result, false)
	}
	
	// MARK: - Inclusive tests
	
	@inline(__always)
	private func _testRunner(pattern: String, regex: String, files: [String], expectedResults: [String], file: StaticString = #file, line: UInt = #line) throws {
		let spec = try XCTUnwrap(GitIgnoreSpec(pattern: pattern), file: file, line: line)
		XCTAssertTrue(spec.inclusive, file: file, line: line)
		XCTAssertEqual(spec.regex.pattern, regex, file: file, line: line)
		let results = spec.match(files: files)
		XCTAssertEqual(results, expectedResults, file: file, line: line)
	}
	
	func testAbsolute() throws {
		try _testRunner(
			pattern: "/an/absolute/file/path",
			regex: "^an/absolute/file/path(?:/.*)?$",
			files: [
				"an/absolute/file/path",
				"an/absolute/file/path/foo",
				"foo/an/absolute/file/path",
			],
			expectedResults: [
				"an/absolute/file/path",
				"an/absolute/file/path/foo",
			]
		)
	}
	
	func testAbsoluteSingleItem() throws {
		try _testRunner(
			pattern: "/an/",
			regex: "^an/.*$",
			files: [
				"an/absolute/file/path",
				"an/absolute/file/path/foo",
				"foo/an/absolute/file/path",
			],
			expectedResults: [
				"an/absolute/file/path",
				"an/absolute/file/path/foo",
			]
		)
	}
	
	func testRelative() throws {
		try _testRunner(
			pattern: "spam",
			regex:  "^(?:.+/)?spam(?:/.*)?$",
			files: [
				"spam",
				"spam/",
				"foo/spam",
				"spam/foo",
				"foo/spam/bar",
			],
			expectedResults: [
				"spam",
				"spam/",
				"foo/spam",
				"spam/foo",
				"foo/spam/bar",
			]
		)
	}
	
	func testRelativeNested() throws {
		try _testRunner(
			pattern: "foo/spam",
			regex: "^foo/spam(?:/.*)?$",
			files: [
				"foo/spam",
				"foo/spam/bar",
				"bar/foo/spam",
			],
			expectedResults: [
				"foo/spam",
				"foo/spam/bar",
			]
		)
	}
	
	func testChildDoubleAsterisk() throws {
		try _testRunner(
			pattern: "spam/**",
			regex: "^spam/.*$",
			files: [
				"spam/bar",
				"foo/spam/bar"
			],
			expectedResults: [
				"spam/bar"
			]
		)
	}
	
	func testInnerDoubleAsterisk() throws {
		try _testRunner(
			pattern: "left/**/right",
			regex: "^left(?:/.+)?/right(?:/.*)?$",
			files: [
				"left/bar/right",
				"left/foo/bar/right",
				"left/bar/right/foo",
				"foo/left/bar/right",
			],
			expectedResults: [
				"left/bar/right",
				"left/foo/bar/right",
				"left/bar/right/foo",
			]
		)
	}
	
	func testOnlyDoubleAsterisk() throws {
		try _testRunner(
			pattern: "**",
			regex: "^.+$",
			files: [],
			expectedResults: []
		)
	}
	
	func testParentDoubleAsterisk() throws {
		try _testRunner(
			pattern: "**/spam",
			regex: "^(?:.+/)?spam(?:/.*)?$",
			files: [
				"foo/spam",
				"foo/spam/bar",
			],
			expectedResults: [
				"foo/spam",
				"foo/spam/bar",
			]
		)
	}
	
	func testInfixWildcard() throws {
		try _testRunner(
			pattern: "foo-*-bar",
			regex: "^(?:.+/)?foo-[^/]*-bar(?:/.*)?$",
			files: [
				"foo--bar",
				"foo-hello-bar",
				"a/foo-hello-bar",
				"foo-hello-bar/b",
				"a/foo-hello-bar/b",
			],
			expectedResults: [
				"foo--bar",
				"foo-hello-bar",
				"a/foo-hello-bar",
				"foo-hello-bar/b",
				"a/foo-hello-bar/b",
			]
		)
	}
	
	func testPostfixWildcard() throws {
		try _testRunner(
			pattern: "~temp-*",
			regex: "^(?:.+/)?~temp-[^/]*(?:/.*)?$",
			files: [
				"~temp-",
				"~temp-foo",
				"~temp-foo/bar",
				"foo/~temp-bar",
				"foo/~temp-bar/baz",
			],
			expectedResults: [
				"~temp-",
				"~temp-foo",
				"~temp-foo/bar",
				"foo/~temp-bar",
				"foo/~temp-bar/baz",
			]
		)
	}
	
	func testPrefixWildcard() throws {
		try _testRunner(
			pattern: "*.swift",
			regex: "^(?:.+/)?[^/]*\\.swift(?:/.*)?$",
			files: [
				"bar.swift",
				"bar.swift/",
				"foo/bar.swift",
				"foo/bar.swift/baz",
			],
			expectedResults: [
				"bar.swift",
				"bar.swift/",
				"foo/bar.swift",
				"foo/bar.swift/baz",
			]
		)
	}
	
	func testDirectory() throws {
		try _testRunner(
			pattern: "dir/",
			regex: "^(?:.+/)?dir/.*$",
			files: [
				"dir/",
				"foo/dir/",
				"foo/dir/bar",
				"dir",
			],
			expectedResults: [
				"dir/",
				"foo/dir/",
				"foo/dir/bar",
			]
		)
	}
	
	func testFailingInitializers() throws {
		XCTAssertThrowsError(try GitIgnoreSpec(pattern: ""))
		XCTAssertThrowsError(try GitIgnoreSpec(pattern: "***"))
	}
}
