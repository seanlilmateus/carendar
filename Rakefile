# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
#require 'motion/project/template/osx'
require './auto_starter_installer'
begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

NAME = [
  77, 97, 116, 101, 117, 115, 32, 65, 114, 109, 97, 110,
  100, 111, 32, 75, 105, 109, 98, 97, 110, 103, 111
].map(&:chr).join

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Carendar'
  app.identifier = 'de.mateus.Carendar'
  app.frameworks += %W[ScriptingBridge QuartzCore Security ServiceManagement EventKit]
  app.info_plist['NSUIElement'] = 1
  app.info_plist['CFBundleIconFile'] = 'icon.icns'
  app.copyright = "Copyright © 2015 #{NAME}. All rights reserved."
  app.version = `git log -n 1 --pretty=format:'%h'`
  app.short_version = "1.0β"
  app.release do
    app.codesign_certificate = 'Mac Developer: seanlilmateus@yahoo.de (VHMJ26E3RY)'
    app.entitlements['com.apple.security.app-sandbox'] = true
    app.entitlements['com.apple.security.personal-information.calendars'] = true
    app.entitlements['com.apple.security.temporary-exception.apple-events'] = ["com.apple.iCal"]
    app.category = 'Utilities'
  end
end
MotionBundler.setup