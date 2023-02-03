
Pod::Spec.new do |spec|
  spec.name         = "IMKit"
  spec.version      = "0.0.1"
  spec.summary      = "派IM"

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
  IMKit是建立在派的IM需求上，构建的IM框架
                   DESC

  spec.homepage     = "http://192.168.1.222:14253/fengxj/imkit"

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

  spec.source       = { :git => "http://192.168.1.222:14253/fengxj/imkit.git", :tag => "#{spec.version}" }


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
