import Foundation
import FoundationExtensions

public struct Time: Equatable {
    private let _seconds: TimeInterval

    public init(totalMilliseconds: TimeInterval) {
        self._seconds = totalMilliseconds / 1000
    }

    public init(totalSeconds: TimeInterval) {
        self._seconds = totalSeconds
    }

    public init(hours: Int, minutes: Int, seconds: Int, milliseconds: Double = 0) {
        self._seconds = (((Double(hours) * 60.0) + Double(minutes)) * 60.0 + Double(seconds)) + milliseconds / 1000
    }

    public var totalHours: Double {
        return _seconds / (60 * 60)
    }

    public var totalMinutes: Double {
        return _seconds / 60
    }

    public var totalSeconds: Double {
        return _seconds
    }

    public var totalMilliseconds: Double {
        return _seconds * 1000
    }

    public var hours: Int {
        return Int(totalHours)
    }

    public var minutes: Int {
        return Int(totalMinutes) - hours * 60
    }

    public var seconds: Int {
        return Int(totalSeconds) - hours * 60 * 60 - minutes * 60
    }

    public var milliseconds: Int {
        return Int(totalMilliseconds) - hours * 60 * 60 * 1000 - minutes * 60 * 1000 - seconds * 1000
    }
}

extension Time: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Time(rawValue: string)
    }
}

extension Time: RawRepresentable {
    public init(rawValue: String) {
        self.init(stringLiteral: rawValue)
    }

    public var rawValue: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumIntegerDigits = 10
        numberFormatter.minimumIntegerDigits = 2
        let timeString = [
            numberFormatter.string(from: hours as NSNumber),
            numberFormatter.string(from: minutes as NSNumber),
            seconds > 0 || milliseconds > 0 ? numberFormatter.string(from: seconds as NSNumber) : nil
        ].compactMap(identity).joined(separator: ":") + (
            milliseconds > 0 ? ",\(milliseconds)" : ""
        )

        return timeString
    }
}

extension Time: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        let parts = value.split(whereSeparator: [":", ",", "."].contains).map(String.init)
        let hours = parts[safe: 0].flatMap(Int.init) ?? 0
        let minutes = parts[safe: 1].flatMap(Int.init) ?? 0
        let seconds = parts[safe: 2].flatMap(Int.init) ?? 0
        let milliseconds = parts[safe: 3].flatMap(Double.init) ?? 0
        self.init(hours: hours, minutes: minutes, seconds: seconds, milliseconds: milliseconds)
    }
}

extension Time: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

extension Time: LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(rawValue: description)
    }
}

extension Time: Comparable {
    public static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs._seconds < rhs._seconds
    }
}

extension Time {
    public static var zero: Time {
        return .init(totalSeconds: 0)
    }
}
