source 'http://rubygems.org'

gem 'rails', '3.2.8'

if RUBY_PLATFORM !~ /mswin|mingw/
#  gem 'rdiscount', :git => 'git://github.com/ricodigo/rdiscount.git'

  gem 'ruby-stemmer', '~> 0.8.2', :require => 'lingua/stemmer'
  gem 'sanitize', '2.0.3'

  gem 'magic'
  gem 'mini_magick', '~> 2.3'
  gem 'nokogiri'
  gem 'mechanize'
else
  gem 'maruku', '0.6.0'
end
gem 'maruku'

# ui
gem 'haml', '>= 3.1.3'
gem 'sass', '>= 3.1.10'
gem 'compass-colors', '0.9.0'
gem 'fancy-buttons', '1.1.1'
gem 'kaminari'
gem 'mustache'


# mongodb
gem 'mongoid'
gem 'mongoid-grid_fs'
gem 'mongoid_ext', :git => 'git://github.com/jameszhan/mongoid_ext.git'

gem 'xapian-ruby', '1.2.7.1'
gem 'xapit', :git => 'git://github.com/jameszhan/xapit.git'

gem 'redis'
gem 'redis-store'
gem 'redis-rails'

# utils
gem 'whatlanguage', '1.0.0'
gem 'uuidtools', '~> 2.1.1'

gem 'goalie', '~> 0.0.4'
gem 'dynamic_form'
gem 'rinku', '~> 1.2.2', :require => 'rails_rinku'

gem 'rack-recaptcha', '0.2.2', :require => 'rack/recaptcha'

gem 'stripe'
gem 'pdfkit' # apt-get install wkhtmltopdf

gem 'geoip'
gem 'rubyzip', '0.9.4', :require => 'zip/zip'


# authentication
gem 'omniauth', '1.1.1'

gem 'orm_adapter'

gem 'devise'
gem 'devise-encryptable'

gem 'whenever', :require => false
gem 'rack-ssl', :require => false

gem 'state_machine', '1.1.2'


group :assets do
  gem 'compass-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end
gem 'yui-compressor'
gem 'jquery-rails'



group :deploy do
  gem 'thin'
  gem 'jammit'
  gem 'capistrano', '2.9.0', :require => false
  gem 'unicorn', '4.1.1', :require => false
  gem 'therubyracer'
end

group :scripts do
  gem 'eventmachine', '~> 0.12.10'
  gem 'em-websocket', '~> 0.3.0'
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'launchy'
  gem 'ffaker'
  gem 'simplecov'
  gem 'autotest'
  gem 'fabrication'
end

group :development do
  gem 'pry'
  gem 'pry-rails'
  gem 'database_cleaner'
  gem 'rspec', '>= 2.0.1'
  gem 'rspec-rails', '>= 2.0.1'
  gem 'remarkable_mongoid', '>= 0.5.0'
  gem 'hpricot'
  gem 'ruby_parser'
  gem 'niftier-generators', '0.1.2'
  gem 'ruby-prof'
end

