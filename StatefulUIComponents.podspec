Pod::Spec.new do |s|
  s.name             = 'StatefulUIComponents'
  s.version          = '1.2.0' # Обновите версию
  s.summary          = 'A collection of customizable UI components with state-specific properties, placeholder text views, and IBInspectable extensions.'
  
  s.description      = <<-DESC
StatefulUIComponents provides:
- @IBDesignable StatefulUIButton with state-specific properties
- PlaceholderTextView with customizable placeholder
- Powerful IBInspectable extensions for all UIView subclasses
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
