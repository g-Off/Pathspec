//
//  Pathspec.swift
//  Pathspec
//
//  Created by Geoffrey Foster on 2019-06-29.
//

public final class Pathspec {
	private let specs: [Spec]
	
	public init(patterns: String...) {
		specs = patterns.compactMap {
			GitIgnoreSpec(pattern: $0)
		}
	}
	
	public func match(path: String) -> Bool {
		let matchingSpecs = self.matchingSpecs(path: path)
		guard !matchingSpecs.isEmpty else { return false }
		return matchingSpecs.allSatisfy { $0.inclusive }
	}
	
	private func matchingSpecs(path: String) -> [Spec] {
		return specs.filter { $0.match(file: path) }
	}
}
