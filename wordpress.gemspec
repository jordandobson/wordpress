# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wordpress}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jordan Dobson"]
  s.date = %q{2009-06-05}
  s.default_executable = %q{wordpress}
  s.description = %q{The Wordpress gem provides posting to a Wordpress.com blog or a self hosted wordpress by providing your username, password, login url(if you host your blog) and your blog content.}
  s.email = ["jordan.dobson@madebysquad.com"]
  s.executables = []
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/wordpress", "lib/wordpress.rb", "test/test_wordpress.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://github.com/jordandobson/wordpress/tree/master}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{wordpress}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{The Wordpress gem provides posting to a Wordpress.com blog or a self hosted wordpress by providing your username, password, login url(if you host your blog) and your blog content. With this gem, you have access to add a text entry on Wordpress blog by providing these options: title text, body text, and a tag array. You must include at least title text or body text with your post.}
  s.test_files = ["test/test_wordpress.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.8.3"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.3"])
  end
end

