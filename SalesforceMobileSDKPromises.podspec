Pod::Spec.new do |s|

  s.name         = "SalesforceMobileSDKPromises"
  s.version      = "7.0.0"
  s.summary      = "Salesforce Mobile SDK wrappped in Promises - Swift"
  s.homepage     = "https://github.com/trooper2013/SalesforceMobileSDK-iOS-Promises"

  s.license      = { :type => "Salesforce.com Mobile SDK License", :file => "LICENSE.md" }
  s.author       = { "Raj Rao" => "rao.r@salesforce.com" }

  s.platform     = :ios, "11.0"

  s.source       = { :git => "https://github.com/trooper2013/SalesforceMobileSDK-iOS-Promises.git#dev",
                     :tag => "v#{s.version}",
                     :submodules => true }

  s.requires_arc = true
  s.default_subspec  = 'SalesforceMobileSDKPromises'

  s.subspec 'SalesforceMobileSDKPromises' do |salesforceswiftpromises|
      salesforceswiftpromises.dependency 'PromiseKit', '~> 6.0'
      salesforceswiftpromises.dependency 'SmartSync'
      salesforceswiftpromises.source_files = 'SalesforceMobileSDKPromises/**/*.{h,m,swift}'
      salesforceswiftpromises.requires_arc = true

  end

end
