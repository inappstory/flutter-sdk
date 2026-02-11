#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint inappstory_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'inappstory_plugin'
  s.version          = '0.1.28'
  s.summary          = 'InAppStory SDK Plugin'
  s.description      = <<-DESC
InAppStory SDK Plugin
                       DESC
  s.homepage         = 'https://inappstory.com/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'InAppStory' => 'support@inappstory.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  #s.dependency 'InAppStory', '1.26.7'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
  s.swift_version = '5.0'
  s.vendored_frameworks = 'InAppStorySDK.xcframework'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'inappstory_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
