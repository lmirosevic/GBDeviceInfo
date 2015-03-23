Pod::Spec.new do |s|
  s.name                      = 'GBDeviceInfo'
  s.version                   = '3.1.0'
  s.summary                   = 'Detects the hardware, software and display of the current iOS or Mac OS X device at runtime.'
  s.author                    = 'Luka Mirosevic'      
  s.homepage                  = 'https://github.com/lmirosevic/GBDeviceInfo'
  s.license                   = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.source                    = { :git => 'https://github.com/lmirosevic/GBDeviceInfo.git', :tag => s.version.to_s }

  s.ios.source_files          = 'GBDeviceInfo/*_iOS.{h,m}', 'GBDeviceInfo/GBDeviceInfo.h', 'GBDeviceInfo/GBDeviceInfoTypes_Common.h', 'GBDeviceInfo/GBDeviceInfoInterface.h', 'GBDeviceInfo/GBDeviceInfoCommonUtils.{h,m}'
  s.ios.public_header_files   = 'GBDeviceInfo/*_iOS.h', 'GBDeviceInfo/GBDeviceInfo.h', 'GBDeviceInfo/GBDeviceInfoTypes_Common.h', 'GBDeviceInfo/GBDeviceInfoInterface.h'
  s.osx.source_files          = 'GBDeviceInfo/*_OSX.{h,m}', 'GBDeviceInfo/GBDeviceInfo.h', 'GBDeviceInfo/GBDeviceInfoTypes_Common.h', 'GBDeviceInfo/GBDeviceInfoInterface.h', 'GBDeviceInfo/GBDeviceInfoCommonUtils.{h,m}'
  s.osx.public_header_files   = 'GBDeviceInfo/*_OSX.h', 'GBDeviceInfo/GBDeviceInfo.h', 'GBDeviceInfo/GBDeviceInfoTypes_Common.h', 'GBDeviceInfo/GBDeviceInfoInterface.h'

  s.osx.frameworks            = 'Cocoa', 'CoreServices', 'Foundation'
  s.ios.frameworks            = 'Foundation'

  s.requires_arc              = true

  s.ios.deployment_target     = '5.0'
  s.osx.deployment_target     = '10.6'

  s.ios.dependency 'GBJailbreakDetection', '~> 1.0'
end
