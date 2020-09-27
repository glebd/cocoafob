Pod::Spec.new do |s|
  s.name             = 'CocoaFob'
  s.version          = '2.1.0'
  s.swift_versions   = ['5.1', '5.0']
  s.summary          = 'macOS app registration code verification & generation.'
  s.description      = <<-DESC
CocoaFob is a set of helper code snippets for registration code generation and
verification in Cocoa applications, integrated with registration code
generation in Potion Store <http://www.potionfactory.com/potionstore> and
FastSpring <http://fastspring.com>.
                       DESC

  s.homepage         = 'https://github.com/glebd/cocoafob'
  s.license          = 'BSD'
  s.author           = { 'Gleb Dolgich' => '@glebd' }
  s.source           = { :git => 'https://github.com/glebd/cocoafob.git', :branch => 'master' }

  s.module_name = 'CocoaFob'
  s.platform = :osx
  s.osx.deployment_target = '10.10'

  s.source_files = ['swift5/CocoaFob/*.swift']
end
