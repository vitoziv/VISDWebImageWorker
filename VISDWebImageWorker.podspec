Pod::Spec.new do |s|
    s.name = 'VISDWebImageWorker'
    s.version = '0.1'
    s.license = 'MIT'
    s.summary = 'VISDWebImageWorker is base on SDWebImage but support remake image before save to cache.'
    s.homepage = 'https://github.com/vitoziv/VISDWebImageWorker' 
    s.author = { 'Vito' => 'vvitozhang@gmail.com' }
    s.source = { :git => 'https://github.com/vitoziv/VISDWebImageWorker.git', :tag => "#{s.version.to_s}" }
    s.platform = :ios, '7.0'
    s.source_files = 'VISDWebImageWorker/*.{h,m}'

    s.dependency 'SDWebImage', '~> 3.8.1'
    s.dependency 'VIImageWorker', '~> 0.1'

    s.requires_arc = true
end

