Pod::Spec.new do |s|

  s.name         = "SalesforceMobileSDK-iOS-Promises"
  s.version      = "7.0.0"
  s.summary      = "Salesforce Mobile SDK wrappped in Promises - Swift"
  s.homepage     = "https://github.com/trooper2013/SalesforceMobileSDK-iOS-Promises"

  s.license      = { :type => "Salesforce.com Mobile SDK License", :file => "LICENSE.md" }
  s.author       = { "Raj Rao" => "rao.r@salesforce.com" }

  s.platform     = :ios, "11.0"

  s.source       = { :git => "https://github.com/trooper2013/SalesforceMobileSDK-iOS-Promises.git",
                     :tag => "v#{s.version}",
                     :submodules => true }

  s.requires_arc = true
  s.default_subspec  = 'SalesforceMobileSDK-iOS-Promises'

  s.subspec 'SalesforceMobileSDK-iOS-Promises' do |salesforceswiftpromises|
      salesforceswiftpromises.dependency 'SmartSync', :git => "https://github.com/forcedotcom/SalesforceMobileSDK-iOS.git", :branch => "dev"
      salesforceswiftpromises.dependency 'SmartStore' , :git => "https://github.com/forcedotcom/SalesforceMobileSDK-iOS.git", :branch => "dev"
      salesforceswiftpromises.dependency 'SalesforceSDKCore', :git => "https://github.com/forcedotcom/SalesforceMobileSDK-iOS.git", :branch => "dev"
      salesforceswiftpromises.dependency 'SalesforceAnalytics' , :git => "https://github.com/forcedotcom/SalesforceMobileSDK-iOS", :branch => "dev"
      salesforceswiftpromises.dependency 'PromiseKit', '~> 6.0'
      salesforceswiftpromises.source_files = 'SalesforceMobileSDK-iOS-Promises/**/*.{h,m,swift}'
      salesforceswiftpromises.requires_arc = true

  end

end
