import Foundation

extension String.Encoding {
    public init?(string: String) {
        switch string {
        case "ascii": self = .ascii
        case "nextstep": self = .nextstep
        case "japaneseEUC": self = .japaneseEUC
        case "utf8": self = .utf8
        case "isoLatin1": self = .isoLatin1
        case "symbol": self = .symbol
        case "nonLossyASCII": self = .nonLossyASCII
        case "shiftJIS": self = .shiftJIS
        case "isoLatin2": self = .isoLatin2
        case "unicode": self = .unicode
        case "windowsCP1251": self = .windowsCP1251
        case "windowsCP1252": self = .windowsCP1252
        case "windowsCP1253": self = .windowsCP1253
        case "windowsCP1254": self = .windowsCP1254
        case "windowsCP1250": self = .windowsCP1250
        case "iso2022JP": self = .iso2022JP
        case "macOSRoman": self = .macOSRoman
        case "utf16": self = .utf16
        case "utf16BigEndian": self = .utf16BigEndian
        case "utf16LittleEndian": self = .utf16LittleEndian
        case "utf32": self = .utf32
        case "utf32BigEndian": self = .utf32BigEndian
        case "utf32LittleEndian": self = .utf32LittleEndian
        default: return nil
        }
    }

    public var shortName: String? {
        switch self {
        case .ascii: return "ascii"
        case .nextstep: return "nextstep"
        case .japaneseEUC: return "japaneseEUC"
        case .utf8: return "utf8"
        case .isoLatin1: return "isoLatin1"
        case .symbol: return "symbol"
        case .nonLossyASCII: return "nonLossyASCII"
        case .shiftJIS: return "shiftJIS"
        case .isoLatin2: return "isoLatin2"
        case .unicode: return "unicode"
        case .windowsCP1251: return "windowsCP1251"
        case .windowsCP1252: return "windowsCP1252"
        case .windowsCP1253: return "windowsCP1253"
        case .windowsCP1254: return "windowsCP1254"
        case .windowsCP1250: return "windowsCP1250"
        case .iso2022JP: return "iso2022JP"
        case .macOSRoman: return "macOSRoman"
        case .utf16: return "utf16"
        case .utf16BigEndian: return "utf16BigEndian"
        case .utf16LittleEndian: return "utf16LittleEndian"
        case .utf32: return "utf32"
        case .utf32BigEndian: return "utf32BigEndian"
        case .utf32LittleEndian: return "utf32LittleEndian"
        default: return nil
        }
    }
}

extension String.Encoding: CaseIterable {
    public static var allCases: [String.Encoding] {
        return [
            .ascii,
            .nextstep,
            .japaneseEUC,
            .utf8,
            .isoLatin1,
            .symbol,
            .nonLossyASCII,
            .shiftJIS,
            .isoLatin2,
            .unicode,
            .windowsCP1251,
            .windowsCP1252,
            .windowsCP1253,
            .windowsCP1254,
            .windowsCP1250,
            .iso2022JP,
            .macOSRoman,
            .utf16,
            .utf16BigEndian,
            .utf16LittleEndian,
            .utf32,
            .utf32BigEndian,
            .utf32LittleEndian
        ]
    }
}
