source 'https://rubygems.org'
#source "http://gems.rubyonrails.org" - times out
# Note: the other

#ruby '1.8.7'

mac_osx = (RUBY_PLATFORM =~ /darwin/)

# The activemodel-cautions gem is ours, so not available rubygems.org.
# The .gem file is in vendor/cache - if this is lost, or the gem needs
# updating, the source (along with development instructions in the
# README) is available at:
#  https://github.com/NHSDigital/activemodel-caution.git

gem 'activemodel-caution', '6.1.7.1'
gem 'rails', '6.1.7.1'
gem 'bootsnap', require: false
gem 'webpacker'
# Allow puma version to be overridden in a custom Gemfile
# We need this for puma on Mac OS Monterey, where puma 5.6.2 has
# build issues with Ruby < 3.1: puma builds with openssl 3 and ruby builds with openssl 1.1
unless defined?(BUNDLER_OVERRIDE_PUMA) && BUNDLER_OVERRIDE_PUMA
  gem 'puma'
  gem 'puma-daemon', require: false
end

gem 'activerecord-oracle_enhanced-adapter', '>= 5.2.3'

gem 'activerecord-import'
gem 'activerecord-import-oracle_enhanced'

#gem "prototype-rails"

# Required for Brakename advisory CVE-2018-3741
gem 'rails-html-sanitizer', '>= 1.0.4'

# Removed from core in Rails 4.0:
gem "actionpack-page_caching"
# gem 'protected_attributes', '1.1.4'
# gem 'activerecord-deprecated_finders'

gem 'rack-cache'
gem 'route_translator', '>= 12.1.0'

# We have built our own CentOS 7 binaries for various gems
# (with separate gem files for different ruby versions)
# Copy these into place if needed
def add_custom_centos_7_binaries(gem_dir_basename, gem_fnames)
  gem_dir = if RUBY_PLATFORM == 'x86_64-linux' && File.exist?('/etc/os-release') &&
               File.readlines('/etc/os-release').grep(/^(ID="centos"|VERSION_ID="7")$/).count == 2
              "vendor/#{gem_dir_basename}-x86_64-linux-ruby#{RUBY_VERSION.split('.')[0..1].join}"
            end
  require 'fileutils'
  gem_fnames.each do |gem_fname|
    if gem_dir && Dir.exist?(gem_dir)
      begin
        FileUtils.cp "#{gem_dir}/#{gem_fname}", 'vendor/cache/'
      rescue Errno::EACCES
        # Deployer account may not have write access to vendor/cache/
        # (in which case the file in vendor/cache/ is probably already correct)
      end
    else
      FileUtils.rm_f "vendor/cache/#{gem_fname}"
    end
  end
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # Allow mini_racer version to be overridden in a custom Gemfile
  # We need this for mini_racer on Mac OS Monterey, where the old libv8 no longer compiles
  unless defined?(BUNDLER_OVERRIDE_MINI_RACER) && BUNDLER_OVERRIDE_MINI_RACER
    # We have built our own CentOS 7 binaries for mini_racer
    # (with separate gem files for Ruby 2.7 and Ruby 3.0)
    # Copy these into place if needed
    add_custom_centos_7_binaries('mini_racer', ['mini_racer-0.6.2-x86_64-linux.gem'])
    gem 'libv8-node', '~> 16.10'
    # gem 'mini_racer', '~> 0.6.2'
    gem 'mini_racer', '0.6.2'
  end
end

# We have built our own CentOS 7 binaries for red-arrow and red-parquet
# Copy these into place if needed
add_custom_centos_7_binaries('red-arrow', ['red-arrow-10.0.1-x86_64-linux.gem',
                                           'red-parquet-10.0.1-x86_64-linux.gem'])

group :oracle do
  # Enable running without Oracle
  gem 'ruby-oci8'
end

gem 'pg'
gem 'net-ldap'
gem 'will_paginate', '~> 3.3'

gem 'cancancan', '~> 3.0'

gem 'ndr_support', '~> 5.9.0'
# gem 'ndr_support', tag: 'b9bc1e1', git: 'https://github.com/PublicHealthEngland/ndr_support.git'
gem 'psych', '3.3.2' # Use old psych for YAML on Ruby 3.1 until ndr_support defaults to safe_load
# gem 'psych', '~> 3.3.0' # Use old psych for YAML on Ruby 3.1 until ndr_support defaults to safe_load

gem 'ndr_error', '~> 2.3'
gem 'ndr_import', '~> 10.1', '>= 10.1.2'
gem 'ndr_lookup', '~> 0.1', '>= 0.1.2'
# gem 'ndr_lookup', git: 'https://github.com/NHSDigital/ndr_lookup.git', branch: 'rails_6_support'

gem 'ndr_browser_timings', '~> 0.4.1'
# For debugging
# gem 'ndr_browser_timings', git: 'https://github.com/PublicHealthEngland/ndr_browser_timings.git', branch: 'request_debug'

# For development : gem 'canql', git: 'https://github.com/PublicHealthEngland/canql', branch: 'dev/43/eurocat_rag_combinations'
# gem 'canql', git: 'https://github.com/NHSDigital/canql', branch: 'dev/90/other_screening_status'
gem 'canql', '~> 5.9', '>= 5.9.0'
gem 'ndr_ui', '~> 3.3'
gem 'ndr_pseudonymise', '~> 0.4.2'
gem 'ndr_workflow', '~> 1.2', '>= 1.2.2'

gem 'tnql', '~> 1.1'

gem "mail", ">= 2.1.1", '< 2.8.0' # mail 2.8.0 and 2.8.0.1 have major hidden bugs
gem "mime-types", "< 2.0" # Enable mail to run on Ruby 1.8.7
gem "uuidtools"

gem 'ndr_stats', '0.2.1'

# roo requires nokogiri >=1.5, but nokogiri (1.6.1) requires Ruby version >= 1.9.2.
#gem "nokogiri", ">= 1.5.11"
gem "nokogiri"
gem "yubikey", "~> 1.4.1"
gem "highline", "~> 1.6.0"
gem 'coderay'
gem 'diff-lcs'
gem 'httpi', '2.4.4'
gem 'rubyntlm'

# Require in main bundle for Scotland submissions:
gem 'net-scp'

gem 'loofah', '>= 2.3.1' # address CVE-2019-15587
gem 'rexml', '>= 3.2.5'  # address CVE-2021-28965

# Help translate unstoreable characters:
gem 'unicode_utils'

# Queued job scheduling:
gem 'hobble', '~> 0.1.0'

# We use Rainbow for prettying output of rake tasks
gem 'rainbow'

gem 'notifications-ruby-client'

group :god do
  gem "god", "~> 0.13.0"
end
gem "daemons", "~> 1.1.9"

group :test do
  gem 'simplecov', '>= 0.21.2'

  # Minitest formatters:
  gem 'minitest-fail-fast'
  gem 'minitest-rg'

  gem "launchy"
  gem "mocha", "~> 1.4", :require => false
  #gem "capistrano", ">= 2.5.0", :require => false
  gem "capistrano", ">= 2.5.0", "< 3.0", :require => false # Capistrano 3.0 has some potentially incompatible changes. Leave version unchanged until move to Rails 3 complete

  gem "capybara", '~> 3.0'
  gem 'capybara-screenshot'

  gem 'rails-controller-testing'

  # TODO: we used to use Josh's fork with similar fix. Awaiting released version of main gem:
  gem 'rails-dom-testing', git: 'https://github.com/rails/rails-dom-testing', ref: '917a447'
end

group :profile do
  gem 'ruby-prof'
end

group :rdc do
  gem 'red-parquet', require: 'parquet'
end

group :development, :test do
  gem 'ndr_dev_support', '~> 7.0'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'webmock'

  gem 'awesome_print'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'faker', '~> 2.20.0'
  gem 'pgcli-rails'
end

group :development do
  gem 'railroady'
  gem 'guard'
  gem 'guard-rubocop'
  gem 'guard-shell'
  gem 'guard-test'
  # Conditionally requiring ensures that the Gemfile.lock remains consistent cross-platform.
  gem 'terminal-notifier-guard', :require => (mac_osx ? 'terminal-notifier-guard' : false)
end

# Note: the following work on OpenSUSE 12.1 after # zypper install libv8-3
# gem 'execjs'
# gem 'therubyracer'
# Test with: $ bundle exec ruby -rubygems -e "require 'execjs'; p ExecJS.eval \"'red yellow blue'.split(' ')\""

gem 'ndr_authenticate', '~> 0.3'

# All the old MBIS gems not in era:
gem 'axlsx'
gem 'bootstrap-table-rails'
group :test do
  gem 'capybara-email'
end
gem 'cocoon'
gem 'delayed_job', '~> 4.1'
gem 'delayed_job_active_record'
gem 'jquery-ui-rails'
gem 'paper_trail', '~> 12.0'
gem 'paper_trail-association_tracking'
gem 'possibly'
group :development do
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'rack-mini-profiler'
  gem 'web-console'
end
gem 'regexp-examples'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.x'
gem 'zip-zip' # annoying backwards compatibility for old axlsx version

