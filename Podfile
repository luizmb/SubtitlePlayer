use_frameworks!
workspace 'Subtitle.xcworkspace'

def ios_version() platform :ios, '10.0' end
def watchos_version() platform :watchos, '3.0' end
def tvos_version() platform :tvos, '10.0' end
def macos_version() platform :macos, '10.10' end
def libraries_project() project 'SubtitleLibraries.xcodeproj' end
def apps_project() project 'SubtitleApp.xcodeproj' end

def rxswift() pod 'RxSwift', '5.0.0', :inhibit_warnings => true end
def gzip() pod 'GzipSwift', '5.0.0', :inhibit_warnings => true end

target 'Common iOS' do
    libraries_project
    ios_version
end

target 'Common macOS' do
    libraries_project
    macos_version
end

target 'Common tvOS' do
    libraries_project
    tvos_version
end

target 'Common watchOS' do
    libraries_project
    watchos_version
end

target 'OpenSubtitlesDownloader iOS' do
    libraries_project
    ios_version
    rxswift
end

target 'OpenSubtitlesDownloader macOS' do
    libraries_project
    macos_version
    rxswift
end

target 'OpenSubtitlesDownloader tvOS' do
    libraries_project
    tvos_version
    rxswift
end

target 'OpenSubtitlesDownloader watchOS' do
    libraries_project
    watchos_version
    rxswift
end

target 'SubtitlePlayer iOS' do
    libraries_project
    ios_version
    rxswift
end

target 'SubtitlePlayer macOS' do
    libraries_project
    macos_version
    rxswift
end

target 'SubtitlePlayer tvOS' do
    libraries_project
    tvos_version
    rxswift
end

target 'SubtitlePlayer watchOS' do
    libraries_project
    watchos_version
    rxswift
end

target 'SubtitleApp' do
    apps_project
    ios_version
    rxswift
    gzip
end

target 'SubtitleApp Desktop' do
    apps_project
    macos_version
    rxswift
    gzip
end

target 'SubtitleApp TV' do
    apps_project
    tvos_version
    rxswift
    gzip
end

target 'SubtitleApp watchOS Extension' do
    apps_project
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
