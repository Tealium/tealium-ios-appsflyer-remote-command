Pod::Spec.new do |s|

    # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.name         = "TealiumAppsFlyer"
    s.module_name  = "TealiumAppsFlyer"
    s.version      = "1.0.0"
    s.summary      = "Tealium Swift and AppsFlyer integration"
    s.description  = <<-DESC
    Tealium's integration with AppsFlyer for iOS.
    DESC
    s.homepage     = "https://github.com/Tealium/tealium-ios-appsflyer-remote-command"

    # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.license      = { :type => "Commercial", :file => "LICENSE.txt" }
    
    # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.authors            = { "Tealium Inc." => "tealium@tealium.com",
        "christinasund"   => "christina.sund@tealium.com" }
    s.social_media_url   = "https://twitter.com/tealium"

    # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.swift_version = "5.0"
    s.platform     = :ios, "10.0"
    s.ios.deployment_target = "10.0"    

    # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.source       = { :git => "https://github.com/Tealium/tealium-ios-appsflyer-remote-command.git", :tag => "#{s.version}" }

    # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.ios.source_files      = "Sources/*.{swift}"

    # ――― Dependencies ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
    s.static_framework = true
    s.ios.dependency 'tealium-swift/Core', '~> 1.9'
    s.ios.dependency 'tealium-swift/TealiumRemoteCommands', '~> 1.9'
    s.ios.dependency 'tealium-swift/TealiumDelegate', '~> 1.9'
    s.ios.dependency 'tealium-swift/TealiumTagManagement', '~> 1.9'
    s.ios.dependency 'AppsFlyerFramework', '~> 5.1'

end
