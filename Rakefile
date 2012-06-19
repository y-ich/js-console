task :default => ['js-console.kmz', 'js/bundle.js']

task :install => ['js-console.kmz', 'js-console-load.kml'] do |t|
    copy t.prerequisites[0], File.expand_path('~/Sites/kml')
    copy t.prerequisites[1], File.expand_path('~/Dropbox/KML Loaders')
end

file 'js/js-console.js' => ['js-console.coffee'] do |t|
    sh "coffee -c -o js #{t.prerequisites[0]}"
end

file 'js-console.kmz' => ['doc.kml', 'js/js-console.js'] do |t|
    sh "zip #{t.name} #{t.prerequisites.join(' ')}"
end

file 'js/bundle.js' => ['js/js-console.js'] do |t|
    sh "browserify #{t.prerequisites.join(' ')} -o #{t.name}"
end

