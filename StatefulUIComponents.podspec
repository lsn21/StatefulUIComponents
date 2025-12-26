Pod::Spec.new do |s|
  s.name             = 'StatefulUIComponents'
  s.version          = '1.2.1' # Обновите версию
  s.summary          = 'A collection of customizable UI components with state-specific properties, placeholder text views, and IBInspectable extensions.'
  
  s.description      = <<-DESC
StatefulUIComponents provides:
- @IBDesignable StatefulUIButton with state-specific properties
- PlaceholderTextView with customizable placeholder
- Powerful IBInspectable extensions for all UIView subclasses
                       DESC

  s.homepage         = 'https://github.com/lsn21/StatefulUIComponents'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sergey Lukyanov' => 'lsn21@ya.ru' }
  s.source           = { :git => 'https://github.com/lsn21/StatefulUIComponents.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.source_files = '/Classes/*.swift'
  
  s.frameworks = 'UIKit'
end
