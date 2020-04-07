Pod::Spec.new do |spec|
  spec.name         = "Gini"
  spec.version      = "0.3.0"
  spec.summary      = "Gini library for scanning documents"
  spec.description  = <<-DESC
  Gini provides an information extraction system for analyzing documents (e. g. invoices or
  contracts), specifically information such as the document sender or the amount to pay in an invoice.
                   DESC

  spec.homepage     = "https://www.gini.net/en/developer/"
  spec.license      = { :type => 'Private', :file => 'LICENSE' }
  spec.author           = { 'Gini GmbH' => 'hello@gini.net' }
  spec.social_media_url   = "https://twitter.com/Gini"

  spec.source       = { :git => "https://github.com/gini/gini-ios.git", :tag => "#{spec.version}" }
  spec.swift_version    = '5.0'
  spec.ios.deployment_target = '10.0'
  spec.default_subspec = 'DocumentsAPI'

  spec.subspec 'DocumentsAPI' do |documents|
    documents.source_files = 'Gini/Classes/Documents/**/*'
  end
  
  spec.subspec 'Pinning' do |pinning|
    pinning.xcconfig =
    { 'OTHER_CFLAGS' => '$(inherited) -DPINNING_AVAILABLE' }
    pinning.dependency "TrustKit", "~> 1.6"
    pinning.dependency "Gini/DocumentsAPI"
    pinning.source_files = 'Gini/Classes/Pinning/**/*'
  end

  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Gini/Tests/Classes/*.swift'
    test_spec.resources = 'Gini/Tests/Assets/*'
    test_spec.requires_app_host = true
  end


end
