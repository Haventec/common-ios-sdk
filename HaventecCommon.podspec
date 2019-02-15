Pod::Spec.new do |s|
  s.name             = 'HaventecCommon'
  s.version          = '0.0.2'
  s.summary          = 'SDK providing common functions for interacting with Authenticate & Sanctum APIs.'

  s.description      = <<-DESC
'SDK providing common functions for interacting with Authenticate & Sanctum APIs.'
                       DESC

  s.homepage         = 'https://github.com/Haventec/common-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Clifford Phan' => 'clifford.phan@haventec.com' }
  s.source           = { :git => 'https://github.com/Haventec/common-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'HaventecCommon/Classes/**/*'
 
  s.swift_version = '4.2' 
end
