workspace 'Subtitle.xcworkspace'
project 'Subtitles App.xcodeproj'
use_frameworks!

# Uncomment the next line to define a global platform for your project
def ios_version() platform :ios, '10.0' end
def watchos_version() platform :watchos, '3.0' end
def tvos_version() platform :tvos, '10.0' end
def macos_version() platform :macos, '10.10' end
def rxswift() pod 'RxSwift', '4.5.0', :inhibit_warnings => true end

target 'Common iOS' do
    ios_version
    rxswift
end

target 'Common macOS' do
    macos_version
    rxswift
end

target 'Common tvOS' do
    tvos_version
    rxswift
end

target 'Common watchOS' do
    watchos_version
    rxswift
end

target 'OpenSubtitlesDownloader iOS' do
    ios_version
    rxswift
end

target 'OpenSubtitlesDownloader macOS' do
    macos_version
    rxswift
end

target 'OpenSubtitlesDownloader tvOS' do
    tvos_version
    rxswift
end

target 'OpenSubtitlesDownloader watchOS' do
    watchos_version
    rxswift
end

target 'SubtitlePlayer iOS' do
    ios_version
    rxswift
end

target 'SubtitlePlayer macOS' do
    macos_version
    rxswift
end

target 'SubtitlePlayer tvOS' do
    tvos_version
    rxswift
end

target 'SubtitlePlayer watchOS' do
    watchos_version
    rxswift
end
