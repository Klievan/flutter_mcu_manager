#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint device_manager.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_mcu_manager'
  s.version          = '0.0.1'
  s.summary          = 'Implementation of Nordic\'s Device Manager packages in Flutter which allows for DFU and many more..'
  s.description      = <<-DESC
  mplementation of Nordic\'s Device Manager packages in Flutter which allows for DFU and many more..'
                       DESC
  s.homepage         = 'https://github.com/Klievan/flutter_mcu_manager'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'IoSA Tracking' => 'ivan@iosatracking.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'iOSMcuManagerLibrary'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
