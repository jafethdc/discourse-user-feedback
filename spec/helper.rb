=begin
  require './spec/rails_helper'

  path = './plugins/discourse-user-feedback/plugin.rb'
  source = File.read(path)
  plugin = Plugin::Instance.new(Plugin::Metadata.parse(source), path)
  plugin.activate!

  settings_path = File.join(Rails.root, 'plugins', 'discourse-user-feedback', 'config', 'settings.yml')
  SiteSetting.load_settings(settings_path)
  plugin.initializers.first.call
  =end