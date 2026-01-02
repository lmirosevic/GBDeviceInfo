Pod::Spec.new do |s|
  s.name                      = 'GBDeviceInfo'
  s.version                   = '7.4.0'
  s.summary                   = 'Detects the hardware, software and display of the current iOS or Mac OS X device at runtime.'
  s.author                    = 'Luka Mirosevic'      
  s.homepage                  = 'https://github.com/lmirosevic/GBDeviceInfo'
  s.license                   = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.source                    = { :git => 'https://github.com/lmirosevic/GBDeviceInfo.git', :tag => s.version.to_s }
  s.requires_arc              = true
  s.ios.deployment_target     = '6.0'
  s.osx.deployment_target     = '10.10'
  s.default_subspec           = 'Core'

  s.subspec 'Core' do |ss|
    ss.ios.source_files          = 'GBDeviceInfo/*_iOS.{h,m}', 'GBDeviceInfo/*_Common.{h,m}', 'GBDeviceInfo/GBDeviceInfo.h', 'GBDeviceInfo/GBDeviceInfoInterface.h', 'GBDeviceInfo/GBDeviceInfo_Subclass.h'
    ss.ios.public_header_files   = 'GBDeviceInfo/*_iOS.h', 'GBDeviceInfo/*_Common.h', 'GBDeviceInfo/GBDeviceInfo.h', 'GBDeviceInfo/GBDeviceInfoInterface.h', 'GBDeviceInfo/GBDeviceInfo_Subclass.h'
    ss.osx.source_files          = 'GBDeviceInfo/*_OSX.{h,m}', 'GBDeviceInfo/*_Common.{h,m}', 'GBDeviceInfo/GBDeviceInfo.h', 'GBDeviceInfo/GBDeviceInfoInterface.h', 'GBDeviceInfo/GBDeviceInfo_Subclass.h'
    ss.osx.public_header_files   = 'GBDeviceInfo/*_OSX.h', 'GBDeviceInfo/*_Common.h', 'GBDeviceInfo/GBDeviceInfo.h', 'GBDeviceInfo/GBDeviceInfoInterface.h', 'GBDeviceInfo/GBDeviceInfo_Subclass.h'
    ss.osx.frameworks            = 'Cocoa', 'CoreServices', 'Foundation'
    ss.ios.frameworks            = 'Foundation'
  end

  s.subspec 'Jailbreak' do |ss|
    ss.platform = :ios
    ss.ios.dependency 'GBJailbreakDetection', '~> 1.3'

    ss.pod_target_xcconfig       = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    ss.user_target_xcconfig      = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end
end
