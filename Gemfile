bundle_path 'vendor/bundler_gems'
bin_path 'vendor/bundler_gems/bin'

clear_sources
source 'http://gemcutter.org'

only :features do
  gem 'activerecord', :require_as => 'active_record'
  gem 'activesupport', :require_as => 'active_support'
  gem 'cucumber'
  gem 'sqlite3-ruby', :require_as => 'sqlite3'
end

only :spec do
  gem 'activerecord', :require_as => 'active_record'
  gem 'activesupport', :require_as => 'active_support'
  gem 'rspec'
  gem 'sqlite3-ruby', :require_as => 'sqlite3'
end
