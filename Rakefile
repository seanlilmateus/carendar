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
  app.name = 'Carendar'
  app.sdk_version = '10.10'
  app.entitlements['com.apple.security.app-sandbox'] = true
  app.frameworks += %W[ScriptingBridge CoreFoundation QuartzCore Security ServiceManagement EventKit]
  app.info_plist['NSUIElement'] = 1
  app.info_plist['CFBundleIconFile'] = 'icon.icns'
  app.copyright = "Copyright Mateus Armando © 2014"
  app.short_version = `git log -n 1 --pretty=format:'%h'`
  app.version = '0.8'
end
MotionBundler.setup