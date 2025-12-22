# StatefulUIComponents.podspec
Pod::Spec.new do |s|
  s.name             = "StatefulUIComponents"
  s.version          = "0.1.0"
  s.summary          = "Per-state UIButton styling with IBInspectable support."
  s.description      = "StatefulUIComponents включает StatefulUIButton — UIButton-subclass с per-state фоном, цветом заголовка, шрифтом и количеством строк, с поддержкой IBInspectable/IBDesignable."
  s.homepage         = "https://github.com/lsn21/StatefulUIComponents"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Sergey Lukyanov" => "lsn21@ya.ru" }
  s.source           = { :git => "https://github.com/lsn21/StatefulUIComponents.git", :tag => "0.1.0" }

  s.platforms = { :ios => "11.0" }

  # Исходники
  s.source_files = "StatefulUIComponents/**/*.{swift,h,m}"
  s.exclude_files = ["StatefulUIComponents/**/Examples/**"]

  s.swift_version = "5.0"
  s.dependency "UIKit"

  s.public_header_files = "StatefulUIComponents/**/*.h"
  s.frameworks = ["UIKit"]

  s.compiler_flags = "-mios-version-min=11.0"
end