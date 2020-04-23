//
//  File.swift
//  
//
//  Created by Vincent Esche on 4/23/20.
//

import XCTest
@testable import Pathspec

#if swift(<5.1)
private struct UnwrappingFailure: LocalizedError {
    var errorDescription: String? {
        return "XCTUnwrap failed: throwing an unknown exception"
    }
}
public func XCTUnwrap<T>(_ expression: @autoclosure () throws -> T?, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) throws -> T {
    guard let unwrapped = try expression() else {
        XCTFail(message(), file: file, line: line)
        throw UnwrappingFailure()
    }
    return unwrapped
}
#endif
