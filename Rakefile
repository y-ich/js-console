task :default => ['js-console.kmz']

task :install => ['js-console.kmz'] do |t|
    copy t.prerequisites, File.expand_path('~/Sites/kml')
end

file 'js-console.kmz' => ['doc.kml', 'js/js-console.js'] do |t|
    sh "zip #{t.name} #{t.prerequisites.join(' ')}"
end
