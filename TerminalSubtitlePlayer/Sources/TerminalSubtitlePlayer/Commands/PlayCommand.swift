import ArgumentParser

struct PlayCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "play",
        abstract: "Plays a subtitle file from disk."
    )

    @Option(help: "Path to the Subtitle file to be played")
    var file: String

    @Option(help: "1-based index of line where you want to start the execution. Useful for re-sync. Defaults to 1.")
    var initialLine: Int = 1

    @Option(help: "The encoding to use when reading the subtitle file contents. Defaults to utf8.")
    var encoding: String.Encoding = .utf8

    @Flag(help: "Debugging printing. Defaults to false.")
    var debug: Bool = false

    func run() throws {
        ConsolePlayer
            .play(path: file, encoding: encoding, from: initialLine, debug: debug)
            .inject(World.default.fileRead)
            .sinkBlockingAndExit(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Done!")
                    case let .failure(error):
                        print("Oops:\n\(error)")
                    }
                },
                receiveValue: { _ in }
            )
    }
}
