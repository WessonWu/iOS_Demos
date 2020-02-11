#
# Be sure to run `pod lib lint Thor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Thor'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Thor.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/吴伟鑫/Thor'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '吴伟鑫' => 'wuweixin@4399inc.com' }
  s.source           = { :git => 'https://github.com/吴伟鑫/Thor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version =  '5.0'
  
  # s.resource_bundles = {
  #   'Thor' => ['Thor/Assets/*.png']
  # }
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'Thor/Classes/Core/**/*'
    sp.dependency 'Moya', '~> 13.0.1-private'
    sp.dependency 'HandyJSON', '~> 5.0'
  end
  
  s.subspec 'RxThor' do |sp|
    sp.source_files = 'Thor/Classes/RxThor/**/*'
    sp.dependency 'Thor/Core'
    sp.dependency 'Moya/RxSwift', '~> 13.0.1-private'
  end
  
  s.default_subspecs = 'Core'
end
