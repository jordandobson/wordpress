# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wordpress/version"

Gem::Specification.new do |s|
  s.name        = "wordpress"
  s.version     = Wordpress::VERSION
  s.authors     = ["Jordan Robert Dobson"]
  s.email       = ["jordandobson@gmail.com"]
  s.homepage    = "https://github.com/jordandobson/wordpress"
  s.summary     = %q{The Wordpress gem provides posting to a Wordpress.com blog or a self hosted wordpress by providing your username, password, login url(if you host your blog) and your blog content. With this gem, you have access to add a text entry on Wordpress blog by providing these options: title text, body text, and a tag array. You must include at least title text or body text with your post.}
  s.description = %q{The Wordpress gem provides posting to a Wordpress.com blog or a self hosted wordpress by providing your username, password, login url(if you host your blog) and your blog content.}

  s.rubyforge_project = "wordpress"
  
  s.add_dependency('mechanize', '~> 2.0')
  s.add_development_dependency('mocha')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
