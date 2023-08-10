Pod::Spec.new do |s|
    s.name             = 'Water'
    s.version          = '0.1.0'
    s.summary          = 'Write functional SwiftUI code progressive.'
    s.description      = <<-DESC
    Water is a library to help you write progressive SwiftUI code with functional programming.
    DESC
    s.homepage         = 'https://github.com/OpenLyl/Water'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'MetaSky' => 'creator_meta_sky@163.com' }
    s.source           = { :git => 'https://github.com/OpenLyl/Water.git', :tag => s.version.to_s }
    s.ios.deployment_target = '14.0'
  
    s.source_files = 'Sources/Water/**/*'
  end
  
