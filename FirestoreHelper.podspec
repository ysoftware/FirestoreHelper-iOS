Pod::Spec.new do |s|

  s.name         = "FirestoreHelper"
  s.version      = "0.1"
  s.summary      = "Firestore methods"
  s.description  = "Methods for easier Firestore access."
  s.homepage     = "http://ysoftware.ru/"
  s.license      = "MIT"
  s.author             = { "Yaroslav Erohin" => "ysoftware@users.noreply.github.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :path => '.' }
  s.source_files  = "FirestoreHelper", "FirestoreHelper/**/*.{h,m,swift}"
  s.requires_arc = true
  s.dependency "Firebase/Auth"
  s.dependency "Firebase/Core"
  s.dependency "Firebase/Firestore"
  s.dependency "Result"

end
