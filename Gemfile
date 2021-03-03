source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Do not use fuzzy version matching (~>) with the Ruby version. It doesn't play
# nicely with RVM and we should be explicit since Ruby is such a fundamental
# part of a Rails project. The Ruby version is also locked in place by the
# Docker base image so it won't be updated with fuzzy matching.
ruby '2.5.8'

gem 'conjur-api', '~> 5.3.4'
gem 'activesupport', '~> 5.2.4.3'
gem 'railties', '~> 5.2.4.3'
gem 'actionview', '~> 5.2.4.2'
gem 'rack', '~> 2.2.3'
gem 'json-schema', '~> 2.8'
gem 'listen', '>= 3.0.5', '< 3.2'

# Use Puma as the app server
gem 'puma', '5.1.1'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'cucumber', '~> 2'
  gem 'json_spec', '~> 1.1.5'
  gem 'aruba'
  gem 'rspec', '~> 3'
  gem 'ci_reporter_rspec', '~> 1'
  gem 'pry-byebug'
  gem 'rspec_junit_formatter'
  gem 'rest-client'
  gem 'rspec-rails', '~> 3.7'
end

group :development do
  gem 'bundler-audit'
  gem 'license_finder'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'openapi_client', '~> 1.0.0'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
