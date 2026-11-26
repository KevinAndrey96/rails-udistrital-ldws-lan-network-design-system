source 'https://rubygems.org'

ruby '~> 2.6.0'

# Last patch release of the 4.2 series: adds Ruby 2.4+ support (Integer
# unification) and every security fix published for Rails 4.2.
gem 'rails', '4.2.11.3'

# Assets
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'bootstrap', '~> 4.1.1'
gem 'autoprefixer-rails'

# Authentication and UI helpers
gem 'devise'
gem 'devise-i18n'
gem 'local_time'
gem 'will_paginate', '~> 3.1.0'

# PDF reports
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary', '~> 0.12.6'

group :development, :test do
  gem 'byebug'
  gem 'sqlite3', '~> 1.3.6'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'annotate'
  gem 'erd'
end

group :production do
  gem 'pg', '~> 0.21'
end
