import Foundation

public struct Parser<A> {
    public let run: (inout Substring) -> A?

    public func run(_ str: String) -> (match: A?, rest: Substring) {
        var str = str[...]
        let match = self.run(&str)
        return (match, str)
    }
}

extension Parser {
    public func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
        Parser<B> { str in
            self.run(&str).map(f)
        }
    }

    public func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
        Parser<B> { str in
            let original = str
            let matchA = self.run(&str)
            let parserB = matchA.map(f)
            guard let matchB = parserB?.run(&str) else {
                str = original
                return nil
            }
            return matchB
        }
    }
}

extension Parser {
    #if DEBUG
    public func performance(_ prefix: String = "", indent: Int = 0) -> Parser {
        Parser { str in
            let start = Date()
            let result = self.run(&str)
            let end = Date()
            print(
                Array(repeating: " ", count: indent).joined()
                + prefix
                + DateInterval(start: start, end: end).description
            )
            return result
        }
    }
    #else
    public func performance(_ prefix: String = "", indent: Int = 0) -> Parser { self }
    #endif

    #if DEBUG
    public func debug(_ prefix: String = "", printMatch: Bool = false, printRemaining: Bool = false) -> Parser {
        Parser { str in
            print("\(prefix)[DEBUG] Running Parser")
            if let match = self.run(&str) {
                print("\(prefix)[DEBUG] Matched Parser")
                if printMatch { print("\(prefix)[DEBUG] Matched value: \(match)") }
                if printRemaining { print("\(prefix)[DEBUG] Remaining string: \(str)") }
                return match
            } else {
                print("\(prefix)[DEBUG] Couldn't Match Parser")
                return nil
            }
        }
    }
    #else
    public func debug(_ prefix: String = "", printMatch: Bool = false, printRemaining: Bool = false) -> Parser { self }
    #endif
}

extension Parser where A == Void {
    public static func literal(_ literal: String) -> Parser {
        Parser { str in
            guard str.hasPrefix(literal) else { return nil }
            let newStart = str.index(str.startIndex, offsetBy: literal.count)
            str = str[newStart ..< str.endIndex]
            return ()
        }
    }
}
extension Parser {
    public static func parserWithEffect(
        _ a: @escaping () -> Parser<A>,
        onSuccess: @escaping (A) -> Void,
        onFailure: @escaping () -> Void = { }
    ) -> Parser {
        Parser { str in
            if let match = a().run(&str) {
                onSuccess(match)
                return match
            } else {
                onFailure()
                return nil
            }
        }
    }
}

extension Parser {
    public static func incrementing(start: Int = 1, parser: @escaping (Int) -> Parser) -> Parser {
        var currentNumber = start
        return parserWithEffect(
            { parser(currentNumber) },
            onSuccess: { _ in currentNumber += 1 }
        )
    }
}

extension Parser where A == Character {
    public static let next = Parser { str in
        guard let first = str.first else { return nil }
        let newStart = str.index(str.startIndex, offsetBy: 1)
        str = str[newStart ..< str.endIndex]
        return first
    }

    public static func next(if condition: @escaping (Character) -> Bool) -> Parser<Character> {
        Parser { str in
            guard !str.isEmpty else { return nil }
            let backup = str
            guard let next = Parser<Character>.next.run(&str) else { return nil }

            if condition(next) {
                return next
            } else {
                str = backup
                return nil
            }
        }
    }
}

extension Parser {
    public static var never: Parser {
        Parser { _ in nil }
    }

    public static func always(_ a: A) -> Parser {
        Parser { _ in a }
    }
}

extension Parser {
    public static func zip<B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
        Parser<(A, B)> { str in
            let original = str
            guard let matchA = a.run(&str) else { return nil }
            guard let matchB = b.run(&str) else {
                str = original
                return nil
            }
            return (matchA, matchB)
        }
    }

    public static func zip<B, C>(_ a: Parser<A>, _ b: Parser<B>, _ c: Parser<C> ) -> Parser<(A, B, C)> {
        Parser.zip(a, Parser<B>.zip(b, c)).map { a, bc in (a, bc.0, bc.1) }
    }

    public static func zip<B, C, D>(_ a: Parser<A>, _ b: Parser<B>, _ c: Parser<C>, _ d: Parser<D> ) -> Parser<(A, B, C, D)> {
        Parser.zip(a, Parser<B>.zip(b, c, d)).map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
    }

    public static func zip<B, C, D, E>(_ a: Parser<A>, _ b: Parser<B>, _ c: Parser<C>, _ d: Parser<D>, _ e: Parser<E>) -> Parser<(A, B, C, D, E)> {
        Parser.zip(a, Parser<B>.zip(b, c, d, e)).map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
    }

    public static func zip<B, C, D, E, F>(_ a: Parser<A>, _ b: Parser<B>, _ c: Parser<C>, _ d: Parser<D>, _ e: Parser<E>, _ f: Parser<F>) -> Parser<(A, B, C, D, E, F)> {
        Parser.zip(a, Parser<B>.zip(b, c, d, e, f)).map { a, bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
    }

    public static func zip<B, C, D, E, F, G>(_ a: Parser<A>, _ b: Parser<B>, _ c: Parser<C>, _ d: Parser<D>, _ e: Parser<E>, _ f: Parser<F>, _ g: Parser<G>) -> Parser<(A, B, C, D, E, F, G)> {
        Parser.zip(a, Parser<B>.zip(b, c, d, e, f, g)).map { a, bcdefg in (a, bcdefg.0, bcdefg.1, bcdefg.2, bcdefg.3, bcdefg.4, bcdefg.5) }
    }
}

extension Parser where A == Void {
    public static let zeroOrMoreSpaces = Parser<Substring>.prefix(while: { $0.isWhitespace && !$0.isNewline }).map { _ in () }

    public static let oneOrMoreSpaces = Parser<Substring>
        .prefix(while: {
            $0.isWhitespace && !$0.isNewline
        }).flatMap { $0.isEmpty ? .never : .always(()) }

    public static let zeroOrMoreSpacesOrLines = Parser<Substring>.prefix(while: { $0.isWhitespace }).map { _ in () }

    public static let oneOrMoreLineBreaks = Parser<Substring>.prefix(while: { $0.isNewline }).flatMap { $0.isEmpty ? .never : .always(()) }
}

extension Parser {
    public static func zeroOrMore(_ p: Parser<A>, separatedBy s: Parser<Void> = .literal("")) -> Parser<[A]> {
        Parser<[A]> { str in
            var rest = str
            var matches: [A] = []
            while let match = p.run(&str) {
                rest = str
                matches.append(match)
                if s.run(&str) == nil {
                    return matches
                }
            }
            str = rest
            return matches
        }
    }
}

extension Parser where A == Void {
    public static let lineBreak = Parser<Character>.next(if: { $0.isNewline }).map { _ in }
}

extension Parser {
    public static func oneOf(_ ps: [Parser<A>]) -> Parser {
        Parser<A> { str in
            for p in ps {
                if let match = p.run(&str) {
                    return match
                }
            }
            return nil
        }
    }
}

extension Parser where A == Void {
    public static func not<B>(_ p: Parser<B>) -> Parser {
        Parser { str in
            let backup = str
            if p.run(&str) != nil {
                str = backup
                return nil
            }
            return ()
        }
    }
}

extension Parser {
    public static func fold<Condition>(if condition: Parser<Condition>, then: Parser, else otherwise: Parser) -> Parser {
        Parser { str in
            let backup = str
            if condition.run(&str) != nil {
                str = backup
                return then.run(&str)
            } else {
                str = backup
                return otherwise.run(&str)
            }
        }
    }
}

extension Parser {
    public static func prefix(while repeatedParser: Parser, combine: @escaping (A, A) -> A) -> Parser {
        Parser { str in
            guard var accumulator = repeatedParser.run(&str) else { return nil }
            while let possibleA = repeatedParser.run(&str) {
                accumulator = combine(accumulator, possibleA)
            }
            return accumulator
        }
    }

    public static func prefix<B>(
        while repeatedParser: Parser<B>,
        reduce: (initial: A, transform: (inout A, B) -> Void)
    ) -> Parser {
        Parser { str in
            guard let first = repeatedParser.run(&str) else { return nil }

            var accumulator = reduce.initial
            reduce.transform(&accumulator, first)

            while let possibleB = repeatedParser.run(&str) {
                reduce.transform(&accumulator, possibleB)
            }
            return accumulator
        }
    }
}

extension Parser where A == Substring {
    public static func prefix(while condition: @escaping (Character) -> Bool) -> Parser<Substring> {
        Parser { str in
            let prefix = str.prefix(while: condition)
            guard !prefix.isEmpty else { return prefix }

            let newStart = str.index(str.startIndex, offsetBy: prefix.count)
            str = str[newStart ..< str.endIndex]

            return prefix
        }
    }
}

extension Parser where A == String {
    public static func string<Condition>(until condition: Parser<Condition>) -> Parser {

        return prefix(
            while: Parser<Character>.fold(
                if: condition,
                then: Parser<Character>.never,
                else: Parser<Character>.next
            ),
            reduce: (
                initial: "",
                transform: { (accumulator: inout String, char: Character) -> Void in
                    accumulator.append(char)
                }
            )
        )
    }
}
