Pod::Spec.new do |s|
  s.name           = "Bismuth"
  s.version        = "2.0.0"
  s.platform       = :ios
  s.ios.deployment_target = "10.0"
  s.summary        = "Queue handling"
  s.author         = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.homepage       = "https://github.com/e-sites/#{s.name}"
  s.source         = { :git => "https://github.com/e-sites/#{s.name}.git", :tag => "v#{s.version.to_s}" }
  s.source_files   = "Bismuth/**/*.{h,swift}"
  s.requires_arc   = true
  s.frameworks     = 'Foundation'
  s.swift_versions = [ '4.2', '5.0', '5.3' ]
end
