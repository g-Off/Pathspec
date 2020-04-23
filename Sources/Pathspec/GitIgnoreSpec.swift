//
//  GitIgnoreSpec.swift
//  Pathspec
//
//  Created by Geoffrey Foster on 2019-06-29.
//

import Foundation

struct GitIgnoreSpec: Spec {
    enum Error: Swift.Error {
        case emptyPattern
        case containsPoundPrefix
        case containsTrippleStar
        case emptyRoot
    }

	private(set) var inclusive: Bool = true

    let pattern: String
	let regex: NSRegularExpression

    init(pattern: String) throws {
        self.pattern = pattern

        guard !pattern.isEmpty else { throw Error.emptyPattern }
		guard !pattern.hasPrefix("#") else { throw Error.containsPoundPrefix }
		guard !pattern.contains("***") else { throw Error.containsTrippleStar }
		guard pattern != "/" else { throw Error.emptyPattern }
		
		var pattern = pattern
		if pattern.hasPrefix("!") {
			inclusive = false
			pattern.removeFirst()
		}
		
		if pattern.starts(with: "\\") {
			pattern.removeFirst(2)
		}
		
		var patternSegments = pattern.components(separatedBy: "/")
		if patternSegments[0].isEmpty {
			patternSegments.removeFirst()
		} else if patternSegments.count == 1 || (patternSegments.count == 2 && patternSegments[1].isEmpty) {
			if patternSegments[0] != "**" {
				patternSegments.insert("**", at: 0)
			}
		}
		if patternSegments.count > 1 && patternSegments[patternSegments.index(before: patternSegments.endIndex)].isEmpty  {
			patternSegments[patternSegments.index(before: patternSegments.endIndex)] = "**"
		}
		
		let pathSeparator = "/"
		var regexString = "^"
		var needSlash = false
		let lastIndex = patternSegments.index(before: patternSegments.endIndex)
		for index in patternSegments.startIndex..<patternSegments.endIndex {
			let segment = patternSegments[index]
			
			if segment == "**" {
				if index == patternSegments.startIndex && index == lastIndex {
					regexString += ".+"
				} else if index == patternSegments.startIndex {
					regexString += "(?:.+\(pathSeparator))?"
					needSlash = false
				} else if index == lastIndex {
					regexString += "\(pathSeparator).*"
				} else {
					regexString += "(?:\(pathSeparator).+)?"
					needSlash = true
				}
			} else if segment == "*" {
				if needSlash {
					regexString += "/"
				}
				regexString += "[^\(pathSeparator)+"
				needSlash = true
			} else {
				if needSlash {
					regexString += "/"
				}
				
				regexString += GitIgnoreSpec.globToRegularExpression(glob: segment)
				
				if inclusive && index == lastIndex {
					regexString += "(?:/.*)?"
				}
				
				needSlash = true
			}
		}
		
		regexString += "$"
		
		regex = try NSRegularExpression(pattern: regexString, options: [])
	}
	
	func match(file: String) -> Bool {
		return regex.firstMatch(in: file, options: [], range: NSRange(file.startIndex..<file.endIndex, in: file)) != nil
	}
	
	private static func globToRegularExpression(glob: String) -> String {
		var regex = ""
		var escape = false
		var i = glob.startIndex
		while i < glob.endIndex {
			let char = glob[i]
			i = glob.index(after: i)
			
			if escape {
				escape = false
				regex += NSRegularExpression.escapedPattern(for: "\(char)")
			} else if char == "\\" {
				escape = true
			} else if char == "*" {
				regex += "[^/]*"
			} else if char == "?" {
				regex += "[^/]"
			} else if char == "[" {
				var j = i
				if j < glob.endIndex && glob[j] == "!" {
					j = glob.index(after: j)
				}
				if j < glob.endIndex && glob[j] == "]" {
					j = glob.index(after: j)
				}
				while j < glob.endIndex && glob[j] != "]" {
					j = glob.index(after: j)
				}
				if j < glob.endIndex {
					var expr = "["
					
					if glob[i] == "!" {
						expr += "^"
						i = glob.index(after: i)
					} else if glob[i] == "^" {
						expr += #"\^"#
						i = glob.index(after: i)
					}
					
					if glob[i] == "]" && i != j {
						expr += #"\]"#
						i = glob.index(after: i)
					}
					
					expr += glob[i...j].replacingOccurrences(of: "\\", with: "\\\\")
					regex += expr
					
					j = glob.index(after: j)
					i = j
				} else {
					regex += #"\["#
				}
			} else {
				regex += NSRegularExpression.escapedPattern(for: "\(char)")
			}
		}
		
		return regex
	}
}

extension GitIgnoreSpec: CustomStringConvertible {
    var description: String {
        let pattern = self.pattern.debugDescription
        return "<\(type(of: self)) pattern: \(pattern)>"
    }
}

extension GitIgnoreSpec: CustomDebugStringConvertible {
    var debugDescription: String {
        let pattern = self.pattern.debugDescription
        let regexPattern = self.regex.pattern.debugDescription
        return "<\(type(of: self)) pattern: \(pattern) regex: \(regexPattern)>"
    }
}
