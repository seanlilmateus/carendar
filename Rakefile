# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'carendar'
  app.info_plist['NSUIElement'] = 1
  app.copyright = "Copyright Mateus Armando © 2014"
  app.short_version = `git log -n 1 --pretty=format:'%h'`
  app.version = '0.8'
end
MotionBundler.setup