use_frameworks!
workspace 'Subtitle.xcworkspace'
project 'Subtitles App.xcodeproj'

def ios_version() platform :ios, '10.0' end
def watchos_version() platform :watchos, '3.0' end
def tvos_version() platform :tvos, '10.0' end
def macos_version() platform :macos, '10.10' end

def rxswift
    pod 'RxSwift', '5.0.0', :inhibit_warnings => true
end

def gzip
    # pod 'GzipSwift', '5.0.0', :inhibit_warnings => true
end

target 'Common iOS' do
    ios_version
end

target 'Common macOS' do
    macos_version
end

target 'Common tvOS' do
    tvos_version
end

target 'Common watchOS' do
    watchos_version
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

target 'Subtitles App iOS' do
    ios_version
    rxswift
    gzip
end

target 'Subtitles App macOS' do
    macos_version
    rxswift
    gzip
end

target 'Subtitles App tvOS' do
    tvos_version
    rxswift
    gzip
end

target 'Subtitles App watchOS Extension' do
    watchos_version
    rxswift
    gzip
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['SWIFT_VERSION'] = "5.0"
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = "YES"
        end
    end
end
