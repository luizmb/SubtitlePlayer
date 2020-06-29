import ArgumentParser
import Foundation

extension String.Encoding: ExpressibleByArgument {
    public init?(argument: String) {
        guard let encoding = String.Encoding(string: argument) else { return nil }
        self = encoding
    }
}
