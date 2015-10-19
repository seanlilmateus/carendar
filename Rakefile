# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
#require 'motion/project/template/osx'
require './auto_starter_installer'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Carendar'
  app.entitlements['com.apple.security.app-sandbox'] = true
  app.identifier = 'de.mateus.Carendar'
  frameworks = %W[ScriptingBridge QuartzCore Security ServiceManagement EventKit]
  app.frameworks += frameworks
  app.info_plist['NSUIElement'] = 1
  app.info_plist['CFBundleIconFile'] = 'icon.icns'
  app.copyright = "Copyright © 2015 Mateus Armando. All rights reserved."
  app.copyright = "Copyright © 2015 %s. All rights reserved."
  app.short_version = `git log -n 1 --pretty=format:'%h'`
  app.version = "1.0β"
end
MotionBundler.setup