#
# Be sure to run `pod lib lint XTModuleBLEYiTongMeter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XTModuleBLEYiTongMeter'
  s.version          = '1.0.5'
  s.summary          = 'XTModuleBLEYiTongMeter.描述'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!11

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/leblanc-zx/XTModuleBLEYiTongMeter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'leblanc-zx' => '351706354@qq.com' }
  s.source           = { :git => 'https://github.com/leblanc-zx/XTModuleBLEYiTongMeter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  #s.source_files = 'XTModuleBLEYiTongMeter/*.{h,m}'
  # 配置子目录


  s.subspec 'Socket' do |socket|
  socket.source_files = 'XTModuleBLEYiTongMeter/Socket/*'
  end

  s.subspec 'Models' do |models|
  models.source_files = 'XTModuleBLEYiTongMeter/Models/*'
  end

  s.subspec 'BLEYiTongMeter' do |bleYiTongMeter|
  bleYiTongMeter.source_files = 'XTModuleBLEYiTongMeter/BLEYiTongMeter/*'
  bleYiTongMeter.dependency 'XTModuleBLEYiTongMeter/Models'
  end

  # s.resource_bundles = {
  #   'XTModuleBLEYiTongMeter' => ['XTModuleBLEYiTongMeter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'XTComponentSocket'
  s.dependency 'XTComponentBLE'
  s.dependency 'XTComponentUtils'
  s.dependency 'XTBLELogManager'
end
