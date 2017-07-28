#
# Be sure to run `pod lib lint GoogleStocks.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GoogleStocks'
  s.version          = '0.1.0'
  s.summary          = 'A framework for fetching stock information from the Google Finance API.'

  s.description      = <<-DESC
Google Stocks v0.1.0 allows one to fetch current market price (or last closing price if market is closed) as well as 10 years of historical prices for NYSE, NASDAQ, AMEX, OTCMKTS stocks. 1 month graph is displayed in the example project.
                       DESC

  s.homepage         = 'https://github.com/halvorsen/GoogleStocks'
    s.screenshots     = 'http://aaronhalvorsen.com/resources/GoogleStocks.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Halvorsen' => '“aaron.halvorsen@gmail.com
git config --global user.name  “halvorsen' }
  s.source           = { :git => 'https://github.com/halvorsen/GoogleStocks.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/halvoh'

  s.ios.deployment_target = '8.0'
  s.source_files = 'GoogleStocks/Classes/**/*'
  s.frameworks = 'UIKit', 'Foundation'

end
