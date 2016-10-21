$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'
class Motion::Project::App 
  class << self 
    alias_method :build_before_copy_helper, :build 
    def build(platform, options={})
      # First let the normal `build' method perform its work. 
      build_before_copy_helper(platform, options) 
      # Now the app is built, but not codesigned yet.
      destination = File.join(config.app_bundle(platform), 'Library/LoginItems')
      puts destination
      info 'Create', destination 
      FileUtils.mkdir_p destination
      path = "/carendar-app-launcher/build/#{platform}-10.12-Release/carendar-app-launcher.app"
      helper_path = File.dirname(__FILE__) + path
      info 'Copy', helper_path 
      FileUtils.cp_r helper_path, destination 
    end 
  end 
end
