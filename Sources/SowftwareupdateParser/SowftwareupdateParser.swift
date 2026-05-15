import Foundation
import Parsing
import Version

public struct SowftwareupdateParser {
	public func parse(_ input: String) -> [SoftwareUpdate] {
		return []
	}

	private let sizeUnitParser = OneOf {
		"KiB".map { UnitInformationStorage.kibibytes }
		"K".map { UnitInformationStorage.kibibytes }
	}

	private let updateParser = Parse(SoftwareUpdate.init) {
		Skip { "* Label: " }
		PrefixUpTo("\n").map(String.init) // label
		Skip { "\t Title: " }
		PrefixUpTo(",").map(String.init) // title
		Skip { ", Version: " }
		PrefixUpTo(",")
			.map(String.init)
			.compactMap { Version($0) } // version
		Skip { ", Size: " }
		Double.parser() // size value
		OneOf {
		"KiB".map { UnitInformationStorage.kibibytes }
		"K".map { UnitInformationStorage.kibibytes }
	}
		Skip { ", Reocommended: YES," }
		Optionally {
			Skip { " Action: restart," }
		}.map { $0 != nil }
		Skip { "\n" }
	}
}
