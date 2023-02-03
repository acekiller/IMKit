
Pod::Spec.new do |spec|
  spec.name         = "IMKit"
  spec.version      = "0.0.1"
  spec.summary      = "极光IM的快速集成框架。"

  spec.subspec 'DisplayKit' do |ss|
    ss.source_files = 'IMKit/IMKit/DisplayKit/**/*'

    ss.dependency 'BonMot'
    ss.dependency 'FlexLayout'
    ss.dependency 'Gifu'
    ss.dependency "Texture"
    ss.dependency 'JMessage'
    ss.dependency 'PHAssetResourceInputStream'
    ss.dependency 'YHPopupView'
    ss.dependency 'MJRefresh'
    ss.dependency 'Masonry'
    ss.dependency 'MBProgressHUD'
    ss.dependency 'IQKeyboardManagerSwift'
    ss.dependency 'TZImagePickerController'
    ss.dependency 'AFNetworking'
    ss.dependency 'SnapKit'
    ss.dependency 'RxSwift'
    ss.dependency 'RxCocoa'
    ss.dependency 'RTRootNavigationController'
    ss.dependency 'UITextView+Placeholder'
    
    ss.dependency 'YHPhotoKit'
    ss.dependency 'AccumulateBag'
  end

  spec.subspec 'MessageKit' do |ss|
    ss.source_files = 'IMKit/IMKit/MessageKit/**/*'
    ss.dependency 'JMessage'
    ss.dependency 'FMDB'
    ss.dependency 'RxSwift'
    ss.dependency 'RxCocoa'
    ss.dependency 'AFNetworking'
    ss.dependency 'PHAssetResourceInputStream'
    
  end

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  基于极光IM的UI功能可扩展化开发框架。基于此框架，可以更快速的实现极光IM的集成，降低极光IM的复杂度。同时，在框架中引入了一个小的统计框架AccumulateBag用于实现自建统计服务工能。AccumulateBag的功能参考: https://github.com/acekiller/AccumulateBag.git
                   DESC

  spec.homepage     = "https://github.com/acekiller/IMKit.git"

  spec.license      = "MIT"

  spec.author             = { "fantasy" => "fengxijun51020@hotmail.com" }
  # Or just: spec.author    = "fengxijun"
  # spec.authors            = { "fengxijun" => "fengxj@pan-vision.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "10.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "https://github.com/acekiller/IMKit.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "IMKit/IMKit/**/*"

  # spec.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
    spec.resources = "IMKIt/Resources/**/*"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"
  spec.static_framework = true
  

end
