Pod::Spec.new do |s|
  s.name           = "Bismuth"
  s.version        = "1.0.3"
  s.platform       = :ios
  s.ios.deployment_target = "9.0"
  s.summary        = "Queue handling"
  s.author         = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.homepage       = "https://github.com/e-sites/#{s.name}"
  s.source         = { :git => "https://github.com/e-sites/#{s.name}.git", :tag => s.version.to_s }
  s.source_files   = "Bismuth/**/*.{h,swift}"
  s.requires_arc   = true
  s.swift_version = '4.2'
  s.frameworks     = 'Foundation'
end
