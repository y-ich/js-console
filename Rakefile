task :default => ['js/js-console-bundle.js']

file 'js/js-console.js' => ['js-console.coffee'] do |t|
    sh "coffee -c -o js #{t.prerequisites[0]}"
end

file 'js-console.kmz' => ['doc.kml', 'js/js-console.js'] do |t|
    sh "zip #{t.name} #{t.prerequisites.join(' ')}"
end

file 'js/js-console-bundle.js' => ['js/js-console.js'] do |t|
    sh "browserify #{t.prerequisites.join(' ')} -o #{t.name}"
end

