import Foundation
import Testing
import Version
@testable import SowftwareupdateParser

@Suite struct SowftwareupdateParserTests {
	let parser = SowftwareupdateParser()

	private func fixture(_ name: String) throws -> String {
		let url = try #require(Bundle.module.url(forResource: name, withExtension: "txt"))
		return try String(contentsOf: url, encoding: .utf8)
	}

	// MARK: - No Updates

	@Test func noUpdates() throws {
		let updates = try parser.parse(fixture("no-updates"))
		#expect(updates.isEmpty)
	}

	// MARK: - Regular Updates

	@Test func singleUpdate() throws {
		let updates = try parser.parse(fixture("single-update"))
		#expect(updates.count == 1)

		let update = try #require(updates.first)
		#expect(update.label == "ProVideoFormats-2.2.7")
		#expect(update.title == "Pro Video Formats")
		#expect(update.version == Version(2, 2, 7))
		#expect(update.size == Measurement(value: 9693, unit: .kibibytes))
		#expect(update.recommended == true)
		#expect(update.restart == false)
	}

	@Test func singleOSUpdateWithRestart() throws {
		let updates = try parser.parse(fixture("single-os-update-restart"))
		#expect(updates.count == 1)

		let update = try #require(updates.first)
		#expect(update.label == "macOS Ventura 13.5-22G74")
		#expect(update.title == "macOS Ventura 13.5")
		#expect(update.version == Version(13, 5, 0))
		#expect(update.size == Measurement(value: 3_502_490, unit: .kibibytes))
		#expect(update.recommended == true)
		#expect(update.restart == true)
	}

	@Test func multipleUpdatesWithOS() throws {
		let updates = try parser.parse(fixture("multiple-updates-with-os"))
		#expect(updates.count == 4)

		let mrt = updates[0]
		#expect(mrt.label == "MRTConfigData_10_15-1.93")
		#expect(mrt.title == "MRTConfigData")
		#expect(mrt.version == Version(1, 93, 0))
		#expect(mrt.size == Measurement(value: 4595, unit: .kibibytes))
		#expect(mrt.recommended == true)
		#expect(mrt.restart == false)

		let xProtectPlist = updates[1]
		#expect(xProtectPlist.label == "XProtectPlistConfigData_10_15-2169")
		#expect(xProtectPlist.title == "XProtectPlistConfigData")
		#expect(xProtectPlist.version == Version(2169, 0, 0))
		#expect(xProtectPlist.size == Measurement(value: 975, unit: .kibibytes))
		#expect(xProtectPlist.recommended == true)
		#expect(xProtectPlist.restart == false)

		let xProtectPayloads = updates[2]
		#expect(xProtectPayloads.label == "XProtectPayloads_10_15-109")
		#expect(xProtectPayloads.title == "XProtectPayloads")
		#expect(xProtectPayloads.version == Version(109, 0, 0))
		#expect(xProtectPayloads.size == Measurement(value: 18241, unit: .kibibytes))
		#expect(xProtectPayloads.recommended == true)
		#expect(xProtectPayloads.restart == false)

		let ventura = updates[3]
		#expect(ventura.label == "macOS Ventura 13.5.1-22G90")
		#expect(ventura.title == "macOS Ventura 13.5.1")
		#expect(ventura.version == Version(13, 5, 1))
		#expect(ventura.size == Measurement(value: 1_520_555, unit: .kibibytes))
		#expect(ventura.recommended == true)
		#expect(ventura.restart == true)
	}

	@Test func mixedRestartAndNoRestart() throws {
		let updates = try parser.parse(fixture("mixed-restart-no-restart"))
		#expect(updates.count == 3)

		let efi = updates[0]
		#expect(efi.label == "MacBookAirEFIUpdate2.4-2.4")
		#expect(efi.title == "MacBook Air EFI Firmware Update")
		#expect(efi.version == Version(2, 4, 0))
		#expect(efi.size == Measurement(value: 3817, unit: .kibibytes))
		#expect(efi.recommended == true)
		#expect(efi.restart == true)

		let proApps = updates[1]
		#expect(proApps.label == "ProAppsQTCodecs-1.0")
		#expect(proApps.title == "ProApps QuickTime codecs")
		#expect(proApps.version == Version(1, 0, 0))
		#expect(proApps.size == Measurement(value: 968, unit: .kibibytes))
		#expect(proApps.recommended == true)
		#expect(proApps.restart == false)

		let java = updates[2]
		#expect(java.label == "JavaForOSX-1.0")
		#expect(java.title == "Java for OS X 2012-005")
		#expect(java.version == Version(1, 0, 0))
		#expect(java.size == Measurement(value: 65288, unit: .kibibytes))
		#expect(java.recommended == true)
		#expect(java.restart == false)
	}

	// MARK: - Full Installers

	@Test func fullInstallers() throws {
		let updates = try parser.parse(fixture("full-installers"))
		#expect(updates.count == 3)

		let sequoia = updates[0]
		#expect(sequoia.label == nil)
		#expect(sequoia.title == "macOS Sequoia")
		#expect(sequoia.version == Version(15, 1, 0))
		#expect(sequoia.size == Measurement(value: 14_123_456_789, unit: .kibibytes))
		#expect(sequoia.recommended == nil)
		#expect(sequoia.restart == false)

		let sonoma = updates[1]
		#expect(sonoma.label == nil)
		#expect(sonoma.title == "macOS Sonoma")
		#expect(sonoma.version == Version(14, 6, 1))
		#expect(sonoma.size == Measurement(value: 13_248_985_973, unit: .kibibytes))
		#expect(sonoma.recommended == nil)
		#expect(sonoma.restart == false)

		let ventura = updates[2]
		#expect(ventura.label == nil)
		#expect(ventura.title == "macOS Ventura")
		#expect(ventura.version == Version(13, 7, 0))
		#expect(ventura.size == Measurement(value: 12_157_035_487, unit: .kibibytes))
		#expect(ventura.recommended == nil)
		#expect(ventura.restart == false)
	}
}
