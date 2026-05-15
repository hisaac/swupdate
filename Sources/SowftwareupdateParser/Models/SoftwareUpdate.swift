import Foundation
import Version

public struct SoftwareUpdate {
	let label: String
	let title: String
	let version: Version
	let size: Measurement<UnitInformationStorage>
	let recommended: Bool
	let restart: Bool
}
