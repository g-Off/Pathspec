//
//  Pathspec.swift
//  Pathspec
//
//  Created by Geoffrey Foster on 2019-06-29.
//

public final class Pathspec {
	private let specs: [Spec]
	
	public convenience init(patterns: [String]) throws {
		self.init(specs: try patterns.map {
            try GitIgnoreSpec(pattern: $0)
        })
	}

    public init(specs: [Spec]) {
        self.specs = specs
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

extension Pathspec: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = String

    public convenience init(arrayLiteral: String...) {
        self.init(specs: arrayLiteral.compactMap {
            try? GitIgnoreSpec(pattern: $0)
        })
    }
}

extension Pathspec: CustomStringConvertible {
    public var description: String {
        let specsDescription = specs.map { spec in
            "  " + String(describing: spec)
        }.joined(separator: ",\n")
        return "<\(type(of: self)) specs: [\n\(specsDescription)\n]>"
    }
}

extension Pathspec: CustomDebugStringConvertible {
    public var debugDescription: String {
        let specsDescription = specs.map { spec in
            "  " + String(reflecting: spec)
        }.joined(separator: ",\n")
        return "<\(type(of: self)) specs: [\n\(specsDescription)\n]>"
    }
}
