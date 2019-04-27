import Common
import Foundation

public struct Subtitle {
    let lines: [Line]

    public init(lines: [Line]) {
        self.lines = lines
    }

    public struct Line {
        let start: Time
        let end: Time
        let text: String

        public init(start: Time, end: Time, text: String) {
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
        case text(Int)
        case interval(index: Int)
    }

    return string
        .replacingOccurrences(of: "\r", with: "")
        .split(separator: "\n", maxSplits: Int.max, omittingEmptySubsequences: false)
        .reduce(into: (state: ReadingState.text(1), lines: [Subtitle.Line]())) { (partial, line) in
            let fileLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            switch partial.state {
            case let .text(index):
                if index == Int(fileLine) {
                    partial.state = .interval(index: index)
                    return
                }

                if !fileLine.isEmpty, let lastLine = partial.lines.last {
                    partial.lines[partial.lines.count - 1] = .init(start: lastLine.start,
                                                                    end: lastLine.end,
                                                                    text: lastLine.text.isEmpty
                                                                        ? fileLine.trimmingCharacters(in: .whitespacesAndNewlines)
                                                                        : lastLine.text + "\n" + fileLine)
                }
            case let .interval(index):
                let parts =
                    fileLine
                        .components(separatedBy: "-->")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .map(Time.init(rawValue:))
                guard parts.count == 2 else { return }
                partial.state = .text(index + 1)
                partial.lines.append(.init(start: parts[0], end: parts[1], text: ""))
            }
        }.lines
}
