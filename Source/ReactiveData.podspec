Pod::Spec.new do |s|
  s.name     = 'ReactiveData'
  s.version  = '0.1'
  s.license  = 'MIT'
  s.summary  = 'Reactive Core Data extensions'
  s.author   = { 'Denis Mikhaylov' => 'd.mikhaylov@qiwi.ru' }
  s.description  = 'Reactive Core Data extensions.'
  s.source_files = 'ReactiveData/**/*.{h,m}'
  s.framework    = 'CoreData'
  s.dependency 'ReactiveCocoa', "~> 2.0"
  s.requires_arc = true
end
