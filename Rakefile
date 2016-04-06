# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
#require 'motion/project/template/osx'
require './auto_starter_installer'
begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

NAME = [77, 97, 116, 101, 117, 115, 32, 65, 114, 109, 97, 110,
        100, 111, 32, 75, 105, 109, 98, 97, 110, 103, 111
       ].map(&:chr).join

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Carendar'
  app.entitlements['com.apple.security.app-sandbox'] = true
  app.identifier = 'de.mateus.Carendar'
  frameworks = %W[ScriptingBridge QuartzCore Security ServiceManagement EventKit]
  app.frameworks += frameworks
  app.info_plist['NSUIElement'] = 1
  app.info_plist['CFBundleIconFile'] = 'icon.icns'
  app.copyright = "Copyright © 2015 #{NAME}. All rights reserved."
  app.short_version = `git log -n 1 --pretty=format:'%h'`
  app.version = "1.0β"
end
MotionBundler.setup