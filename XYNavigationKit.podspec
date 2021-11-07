#
# Be sure to run `pod lib lint XYNavigationBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XYNavigationKit'
  s.version          = '1.0.0'
  s.summary          = 'UIViewController 可独立设置 XYNavigationBar 相关属性'

  s.description      = <<-DESC
  UIViewController 可独立设置 XYNavigationBar 相关属性(背景颜色、阴影、tinitColor、是否支持手势等)，之间并且可优雅切换.
                       DESC

  s.homepage         = 'https://github.com/yuan188/XYNavigationKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yuan188' => 'yuan188' }
  s.source           = { :git => 'https://github.com/yuan188/XYNavigationKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'XYNavigationKit/Classes/**/*'
  s.swift_version = '5.0'
end
