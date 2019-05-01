workspace 'Subtitle.xcworkspace'
project 'Subtitles App.xcodeproj'
use_frameworks!

# Uncomment the next line to define a global platform for your project
def ios_version() platform :ios, '10.0' end
def watchos_version() platform :watchos, '3.0' end
def tvos_version() platform :tvos, '10.0' end
def macos_version() platform :macos, '10.10' end
def rxswift() pod 'RxSwift', '5.0.0', :inhibit_warnings => true end

target 'Common iOS' do
    platform :ios, '10.0'
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
    platform :ios, '10.0'
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
    platform :ios, '10.0'
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

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['SWIFT_VERSION'] = "5.0"
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = "YES"

            if target.name == 'RxSwift' && config.name == 'Debug'
                config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
            end
        end
    end
end
