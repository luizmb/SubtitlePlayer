# SubtitlePlayer

Parse and play .srt subtitles in real-time

## Instructions
1. Checkout repo
2. Run `swift build`
3. Run `swift run subt play file=/path/to/subtitle.srt` to play using natural time
4. Run `swift run subt play file=/path/to/subtitle.srt from-line=0` to play from when you hear the first dialog
5. Run `swift run subt play file=/path/to/subtitle.srt from-line=42` to play from a specific dialog (zero-based index). Convenient for popcorn breaks. :)

Requires RxSwift and Swift 5

Framework should be able to run on iOS, macOS, watchOS, tvOS or Linux, however for now only the console app is implemented.