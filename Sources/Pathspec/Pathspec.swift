//
//  Pathspec.swift
//  Pathspec
//
//  Created by Geoffrey Foster on 2019-06-29.
//

public final class Pathspec {
	public enum Kind {
		case git
		case regex
	}
	private var specs: [Spec] = []
	
	public init(kind: Kind, patterns: String...) {
		for pattern in patterns {
			add(pattern: pattern, kind: kind)
		}
	}
	
	public func match(path: String) -> Bool {
		return matchingSpecs(path: path).allSatisfy { $0.inclusive }
	}
	
	func add(pattern: String, kind: Kind) {
		let spec: Spec?
		switch kind {
		case .git:
			spec = GitIgnoreSpec(pattern: pattern)
		case .regex:
			spec = RegexSpec()
		}
		if let spec = spec {
			specs.append(spec)
		}
	}
	
	private func matchingSpecs(path: String) -> [Spec] {
		return specs.filter { $0.match(file: path) }
	}
}
