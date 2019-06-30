//
//  Spec.swift
//  Pathspec
//
//  Created by Geoffrey Foster on 2019-06-29.
//

import Foundation

public protocol Spec {
	var inclusive: Bool { get }
	func match(file: String) -> Bool
}

extension Spec {
	public func match(files: [String]) -> [String] {
		return files.filter { (file) -> Bool in
			match(file: file)
		}
	}
}
