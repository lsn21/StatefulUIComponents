Pod::Spec.new do |s|
  s.name             = 'StatefulUIComponents'
  s.version          = '1.0.0'
  s.summary          = 'A collection of customizable UI components with state-specific properties.'
  
  s.description      = <<-DESC
StatefulUIComponents provides a collection of @IBDesignable UI components that allow you to set different properties for each control state (normal, highlighted, selected, disabled) directly from Interface Builder. Includes StatefulUIButton and more.
                       DESC

  s.homepage         = 'https://github.com/your-username/StatefulUIComponents'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/your-username/StatefulUIComponents.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*.swift'
  
  s.frameworks = 'UIKit'
end
