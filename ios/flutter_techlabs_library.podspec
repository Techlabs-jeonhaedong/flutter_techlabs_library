Pod::Spec.new do |s|
  s.name             = 'flutter_techlabs_library'
  s.version          = '0.1.0'
  s.summary          = 'Techlabs library Flutter bridge'
  s.description      = 'Techlabs library Flutter bridge'
  s.homepage         = 'https://techlabs.global'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'techlabs' => 'dev@techlabs.global' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '15.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.9'
end
