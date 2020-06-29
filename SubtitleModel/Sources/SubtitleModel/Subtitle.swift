import Foundation
import FoundationExtensions

public struct Subtitle: Equatable, Codable {
    public let lines: [Line]

    public var length: Time {
        return lines.map(^\.end).max() ?? .zero
    }

    public var lastSequence: Int {
        return lines.map(^\.sequence).max() ?? .zero
    }

    public init(lines: [Line]) {
        self.lines = lines
    }

    public func line(sequence: Int) -> Line? {
        return lines.first(where: { $0.sequence == sequence })
    }

    public struct Line: Equatable, Codable, Identifiable {
        public var id: Int { sequence }
        public let sequence: Int
        public let start: Time
        public let end: Time
        public let text: String

        public init(sequence: Int, start: Time, end: Time, text: String) {
            self.sequence = sequence
            self.start = start
            self.end = end
            self.text = text
        }
    }
}

extension Subtitle {
    public static func from(filePath: String, encoding: String.Encoding) -> Reader<ReadFileAtPath, Result<Subtitle, SubtitleDecodingError>> {
        return Reader { readFileAtPath in
            readFileAtPath(filePath)
                .mapError { SubtitleDecodingError.readFileError(ReadFileError.cannotReadFile(path: filePath, error: $0)) }
                .flatMap { Subtitle.from(data: $0, encoding: encoding) }
        }
    }

    public static func from(data: Data, encoding: String.Encoding) -> Result<Subtitle, SubtitleDecodingError> {
        return String(data: data, encoding: encoding)
            .toResult(orError: .binaryDataCannotBeRepresentedAsString(encoding: encoding))
            .flatMap(from(string:))

    }

    public static func from(string: String) -> Result<Subtitle, SubtitleDecodingError> {
        let lines = SubtitleParser.parse(string)
        guard lines.count > 0 else { return .failure(.stringCannotBeRepresentedAsSubtitle(string)) }
        return .success(.init(lines: lines))
    }
}
