import Foundation
import Version

public struct SoftwareUpdate {
	/// The label identifier. `nil` for full installer entries, which have no label.
	let label: String?
	let title: String
	let version: Version
	let size: Measurement<UnitInformationStorage>
	/// Whether the update is recommended. `nil` for full installer entries.
	let recommended: Bool?
	let restart: Bool
}
