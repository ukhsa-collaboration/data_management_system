# -*- encoding: utf-8 -*-
# stub: rails-dom-testing 2.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-dom-testing".freeze
  s.version = "2.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rafael Mendon\u00E7a Fran\u00E7a".freeze, "Kasper Timm Hansen".freeze]
  s.date = "2020-10-08"
  s.description = " This gem can compare doms and assert certain elements exists in doms using Nokogiri. ".freeze
  s.email = ["rafaelmfranca@gmail.com".freeze, "kaspth@gmail.com".freeze]
  s.files = ["MIT-LICENSE".freeze, "README.md".freeze, "lib/rails".freeze, "lib/rails-dom-testing.rb".freeze, "lib/rails/dom".freeze, "lib/rails/dom/testing".freeze, "lib/rails/dom/testing/assertions".freeze, "lib/rails/dom/testing/assertions.rb".freeze, "lib/rails/dom/testing/assertions/dom_assertions.rb".freeze, "lib/rails/dom/testing/assertions/selector_assertions".freeze, "lib/rails/dom/testing/assertions/selector_assertions.rb".freeze, "lib/rails/dom/testing/assertions/selector_assertions/count_describable.rb".freeze, "lib/rails/dom/testing/assertions/selector_assertions/html_selector.rb".freeze, "lib/rails/dom/testing/assertions/selector_assertions/substitution_context.rb".freeze, "lib/rails/dom/testing/version.rb".freeze, "test/dom_assertions_test.rb".freeze, "test/selector_assertions_test.rb".freeze, "test/test_helper.rb".freeze]
  s.homepage = "https://github.com/rails/rails-dom-testing".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.4".freeze
  s.summary = "Dom and Selector assertions for Rails applications".freeze
  s.test_files = ["test/selector_assertions_test.rb".freeze, "test/test_helper.rb".freeze, "test/dom_assertions_test.rb".freeze]

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.6"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0.0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
  else
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.6"])
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
  end
end
