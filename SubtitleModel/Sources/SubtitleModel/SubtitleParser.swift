import Foundation
import FunctionalParser

struct SubtitleParser {
    static let parse: (String) -> [Subtitle.Line] = { string in
        parser().run(string).match ?? []
    }
}

func parser() -> Parser<[Subtitle.Line]> {
    let line = Parser.zip(
        sequenceNumber(),
        timeInterval(),
        subtitleText()
    ).map { number, timeInterval, text -> Subtitle.Line in
        let line = Subtitle.Line(
            sequence: number,
            start: timeInterval.startTime,
            end: timeInterval.endTime,
            text: text
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\r\n", with: "\n")
        )
        return line
    }

    return Parser.zip(Parser<Substring>.prefix(while: { $0 != "1" }), Parser<Subtitle.Line>.zeroOrMore(line)).map { _, lines in lines }
}

func sequenceNumber() -> Parser<Int> {
    .incrementing(start: 1) { int in
        Parser.zip(.literal("\(int)"), .zeroOrMoreSpaces, .lineBreak)
            .map { _, _, _ -> Int in int }
    }
}

func time() -> Parser<Time> {
    let timeCharacteres = [Character]("0123456789,:.")
    return Parser<Substring>.prefix(while: timeCharacteres.contains)
        .flatMap { timeString -> Parser<Time> in
            Time(String(timeString)).map(Parser.always) ?? .never
        }
}

func timeInterval() -> Parser<(startTime: Time, endTime: Time)> {
    let arrow = Parser.literal(" --> ")

    return Parser.zip(
        time(),
        arrow,
        time(),
        Parser.lineBreak
    ).map { startTime, _, endTime, _ in (startTime: startTime, endTime: endTime) }
}

func nextRecordHeader() -> Parser<Void> {
    Parser.incrementing(start: 2) { int in
        Parser.zip(
            .literal("\(int)"),
            .zeroOrMoreSpaces,
            .lineBreak,
            time()
        )
    }.map { _, _, _, _ in }
}

func subtitleText() -> Parser<String> {
    .string(until: nextRecordHeader())
}
