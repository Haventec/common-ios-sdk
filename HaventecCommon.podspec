#
# Be sure to run `pod lib lint HaventecCommon.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HaventecCommon'
  s.version          = '1.0.0'
  s.summary          = 'SDK providing common functions for interacting with Authenticate & Sanctum APIs.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
'SDK providing common functions for interacting with Authenticate & Sanctum APIs.'
                       DESC

  s.homepage         = 'https://github.com/Haventec/common-ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Clifford Phan' => 'clifford.phan@haventec.com' }
  s.source           = { :git => 'https://github.com/Clifford Phan/HaventecCommon.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'HaventecCommon/Classes/**/*'
 
  s.swift_version = '4.2' 
  # s.resource_bundles = {
  #   'HaventecCommon' => ['HaventecCommon/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
