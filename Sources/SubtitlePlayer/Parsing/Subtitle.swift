import Common
import Foundation

public struct Subtitle: Equatable {
    public let lines: [Line]

    public init(lines: [Line]) {
        self.lines = lines
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
    public static func from(filePath: String, encoding: String.Encoding) -> Reader<FileManagerProtocol, Subtitle?> {
        return Reader { fileManager in
            fileManager
                .contents(atPath: filePath)
                .flatMap { Subtitle.from(data: $0, encoding: encoding) }
        }
    }

    public static func from(data: Data, encoding: String.Encoding) -> Subtitle? {
        return String(data: data, encoding: encoding)
            .map(from(string:))
    }

    public static func from(string: String) -> Subtitle {
        return .init(lines: extractLines(from: string))
    }
}

private func extractLines(from string: String) -> [Subtitle.Line] {
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
