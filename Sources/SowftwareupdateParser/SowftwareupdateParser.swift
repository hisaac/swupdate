import Foundation
import Parsing
import Version

// MARK: - Errors

public enum SowftwareupdateParserError: Error {
	case invalidHeader
	case unknownFormat
}

private struct ParseFailure: Error {
	let summary: String
}

// MARK: - Component Parsers

/// Parses a version string of the form `major[.minor[.patch]]` using `Version`'s tolerant initializer.
private struct VersionParser: Parser {
	func parse(_ input: inout Substring) throws -> Version {
		let versionString = input.prefix(while: { $0.isNumber || $0 == "." })
		guard !versionString.isEmpty, let version = Version(tolerant: versionString) else {
			throw ParseFailure(summary: "Expected version string")
		}
		input.removeFirst(versionString.count)
		return version
	}
}

/// Parses a size string of the form `<number>K` or `<number>KiB`.
private struct SizeParser: Parser {
	func parse(_ input: inout Substring) throws -> Measurement<UnitInformationStorage> {
		let digits = input.prefix(while: { $0.isNumber })
		guard !digits.isEmpty, let value = Double(digits) else {
			throw ParseFailure(summary: "Expected numeric size value")
		}
		input.removeFirst(digits.count)
		if input.hasPrefix("KiB") {
			input.removeFirst(3)
			return Measurement(value: value, unit: .kibibytes)
		} else if input.first == "K" {
			input.removeFirst()
			return Measurement(value: value, unit: .kibibytes)
		}
		throw ParseFailure(summary: "Expected size unit 'K' or 'KiB'")
	}
}

// MARK: - Entry Parsers

/// Parses a regular software update entry:
/// ```
/// * Label: <label>\n
/// \t Title: <title>, Version: <version>, Size: <size>, Recommended: YES|NO[, Action: restart],\n
/// ```
private struct RegularUpdateParser: Parser {
	func parse(_ input: inout Substring) throws -> SoftwareUpdate {
		try "* Label: ".parse(&input)
		let label = String(try PrefixUpTo("\n").parse(&input))
		try "\n\t Title: ".parse(&input)
		let title = String(try PrefixUpTo(", Version: ").parse(&input))
		try ", Version: ".parse(&input)
		let version = try VersionParser().parse(&input)
		try ", Size: ".parse(&input)
		let size = try SizeParser().parse(&input)
		try ", Recommended: ".parse(&input)
		let recommended: Bool
		if input.hasPrefix("YES") {
			input.removeFirst(3)
			recommended = true
		} else if input.hasPrefix("NO") {
			input.removeFirst(2)
			recommended = false
		} else {
			throw ParseFailure(summary: "Expected 'YES' or 'NO'")
		}
		let restart: Bool
		if input.hasPrefix(", Action: restart,") {
			input.removeFirst(", Action: restart,".count)
			restart = true
		} else if input.first == "," {
			input.removeFirst()
			restart = false
		} else {
			throw ParseFailure(summary: "Expected ',' or ', Action: restart,'")
		}
		if input.first == "\n" { input.removeFirst() }
		return SoftwareUpdate(
			label: label,
			title: title,
			version: version,
			size: size,
			recommended: recommended,
			restart: restart
		)
	}
}

/// Parses a full installer entry:
/// ```
/// * Title: <title>, Version: <version>, Size: <size>\n
/// ```
private struct FullInstallerParser: Parser {
	func parse(_ input: inout Substring) throws -> SoftwareUpdate {
		try "* Title: ".parse(&input)
		let title = String(try PrefixUpTo(", Version: ").parse(&input))
		try ", Version: ".parse(&input)
		let version = try VersionParser().parse(&input)
		try ", Size: ".parse(&input)
		let size = try SizeParser().parse(&input)
		if input.first == "\n" { input.removeFirst() }
		return SoftwareUpdate(
			label: nil,
			title: title,
			version: version,
			size: size,
			recommended: nil,
			restart: false
		)
	}
}

// MARK: - Main Parser

public struct SowftwareupdateParser {
	public init() {}

	public func parse(_ input: String) throws -> [SoftwareUpdate] {
		var rest = input[...]

		// Skip everything up to and including the "Finding available software\n" header line.
		// The header may or may not have a blank line after "Software Update Tool".
		guard let headerEnd = rest.range(of: "Finding available software\n") else {
			throw SowftwareupdateParserError.invalidHeader
		}
		rest = rest[headerEnd.upperBound...]

		if rest.hasPrefix("No new software available.") {
			return []
		}

		let regularPrefix = "Software Update found the following new or updated software:\n"
		if rest.hasPrefix(regularPrefix) {
			rest.removeFirst(regularPrefix.count)
			return try Many { RegularUpdateParser() }.parse(&rest)
		}

		let fullPrefix = "Software Update found the following full installers:\n"
		if rest.hasPrefix(fullPrefix) {
			rest.removeFirst(fullPrefix.count)
			return try Many { FullInstallerParser() }.parse(&rest)
		}

		throw SowftwareupdateParserError.unknownFormat
	}
}
