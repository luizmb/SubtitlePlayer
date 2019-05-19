import Common
import Foundation

public struct Subtitle: Equatable {
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

    public struct Line: Equatable {
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
    public static func from(filePath: String, encoding: String.Encoding) -> Reader<FileManagerProtocol, Result<Subtitle, Error>> {
        return Reader { fileManager in
            fileManager
                .contents(atPath: filePath)
                .toResult(orError: FileManagerError.fileNotFound(fileName: filePath, parent: URL(fileURLWithPath: filePath).deletingLastPathComponent(), childrenFoundOnParent: []))
                .flatMap { Subtitle.from(data: $0, encoding: encoding).mapError(^\.self) }
        }
    }

    public static func from(data: Data, encoding: String.Encoding) -> Result<Subtitle, SubtitleDecodingError> {
        return String(data: data, encoding: encoding)
            .toResult(orError: .binaryDataCannotBeRepresentedAsString(encoding: encoding)) 
            .flatMap(from(string:))

    }

    public static func from(string: String) -> Result<Subtitle, SubtitleDecodingError> {
        let lines = extractLines(from: string)
        guard lines.count > 0 else { return .failure(.stringCannotBeRepresentedAsSubtitle(string)) }
        return .success(.init(lines: lines))
    }
}

private func extractLines(from string: String) -> [Subtitle.Line] {
    let scanner = Scanner(string: string)
    scanner.charactersToBeSkipped = .whitespacesAndNewlines
    let timeCharacteres = CharacterSet(charactersIn: "0123456789,:.")

    var currentNumber = 1
    var accumulator = [Subtitle.Line]()
    while let _ = scanner.scanString(str: "\(currentNumber)") {
        guard
            let startTime = scanner.scanCharacters(from: timeCharacteres).flatMap(Time.init),
            let _ = scanner.scanString(str: "-->"),
            let endTime = scanner.scanCharacters(from: timeCharacteres).flatMap(Time.init),
            let text = scanner.scanUpToString(str: "\(currentNumber + 1)") else {
            return accumulator
        }

        accumulator.append(.init(
            sequence: currentNumber,
            start: startTime,
            end: endTime,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines)))
        currentNumber += 1
    }
    return accumulator
}

private func extractLinesOld(from string: String) -> [Subtitle.Line] {
    enum ReadingState {
        case timeInterval(sequence: Int)
        case text(nextSequence: Int)
    }

    return string
        .replacingOccurrences(of: "\r", with: "")
        .split(separator: "\n", maxSplits: Int.max, omittingEmptySubsequences: false)
        .reduce(into: (state: ReadingState.text(nextSequence: 1), lines: [Subtitle.Line]())) { (partial, line) in
            let fileLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            switch partial.state {
            case let .text(nextSequence):
                if nextSequence == Int(fileLine) {
                    partial.state = .timeInterval(sequence: nextSequence)
                    return
                }

                if !fileLine.isEmpty, let lastLine = partial.lines.last {
                    partial.lines[partial.lines.count - 1] = .init(
                        sequence: lastLine.sequence,
                        start: lastLine.start,
                        end: lastLine.end,
                        text: lastLine.text.isEmpty
                            ? fileLine
                            : "\(lastLine.text)\n\(fileLine)"
                    )
                }
            case let .timeInterval(sequence):
                let parts = fileLine
                    .components(separatedBy: "-->")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .map(Time.init(rawValue:))
                guard parts.count == 2 else { return }
                partial.state = .text(nextSequence: sequence + 1)
                partial.lines.append(.init(sequence: sequence, start: parts[0], end: parts[1], text: ""))
            }
        }.lines
}
