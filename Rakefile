task :default => ['js-console.kmz']

task :install => ['js-console.kmz', 'js-console-load.kml'] do |t|
    copy t.prerequisites[0], File.expand_path('~/Sites/kml')
    copy t.prerequisites[1], File.expand_path('~/Dropbox/KML Loader')
end

file 'js-console.kmz' => ['doc.kml', 'js/js-console.js'] do |t|
    sh "zip #{t.name} #{t.prerequisites.join(' ')}"
end
