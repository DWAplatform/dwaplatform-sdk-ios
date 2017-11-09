Pod::Spec.new do |s|
  s.name                  = "DWAplatform"
  s.version               = "1.1.1"
  s.summary               = "DWAplatform SDK for iOS."
  s.homepage              = "https://github.com/DWAplatform/dwaplatform-sdk-ios"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "Tiziano Cappellari" => "tiziano.cappellari@dwafintech.com" }
  s.platform              = :ios
  s.ios.deployment_target = "8.0"
  s.source                = { :git => "https://github.com/DWAplatform/dwaplatform-sdk-ios.git", :tag => "#{s.version}" }
  s.source_files          = "DWAplatform/**/*.swift"
end
