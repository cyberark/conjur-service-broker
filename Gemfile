source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '~> 3.1'

gem 'conjur-api', '~> 5.3.4'
gem 'activesupport', '~> 6.1'
gem 'railties', '~> 6.1'
gem 'actionview', '~> 6.1'
gem 'rack', '~> 2.2.6'
gem 'json-schema', '2.8.0'
gem 'listen', '>= 3.0.5', '< 3.2'

# Use Puma as the app server
gem 'puma', '6.4.2'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'cucumber', '~> 7.1.0'
  gem 'json_spec', '~> 1.1.5'
  gem 'aruba'
  gem 'rspec', '~> 3'
  gem 'ci_reporter_rspec', '~> 1'
  gem 'pry-byebug'
  gem 'rspec_junit_formatter'
  gem 'rest-client'
  gem 'rspec-rails', '~> 6.0'
end

group :development do
  gem 'bundler-audit'
  gem 'license_finder'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
