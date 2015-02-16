#
# Be sure to run `pod lib lint ARNPageContainer-Swift.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ARNPageContainer-Swift"
  s.version          = "0.1.0"
  s.summary          = " Horizontal Scroll Paging ViewController Container. (Swift lang)"
  s.homepage         = "https://github.com/xxxAIRINxxx/ARNPageContainer-Swift"
  # s.screenshots    = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "xxxAIRINxxx" => "xl1138@gmail.com" }
  s.source           = { :git => "https://github.com/xxxAIRINxxx/ARNPageContainer-Swift.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = "Lib/*.swift"
  s.resource_bundles = {
    'ARNPageContainer-Swift' => ['Lib/*.png']
  }

  # s.frameworks = 'UIKit', 'MapKit'
end