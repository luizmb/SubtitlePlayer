import ArgumentParser
import Foundation

struct TerminalSubtitlePlayer: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "subplayer",
        abstract: "Command-line Tools for subtitles",
        subcommands: [DownloadCommand.self, PlayCommand.self, SearchCommand.self]
    )
}
