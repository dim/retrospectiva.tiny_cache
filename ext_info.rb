#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
require File.dirname(__FILE__) + '/tiny_git/caching/persistent_cache'

unless Rails.env.test?
  config = YAML.load_configuration(File.dirname(__FILE__) + '/config.yml', {})
  store  = config['common']['store'].to_sym
  
  params = case store
  when :file_store, :partitioned_file_store
    config['file']['path']
  when :tokyo_store
    [config['tokyo']['host'], config['tokyo']['port']]
  when :mem_cache_store, :memcached_store
    config['mem_cache']['servers']
  end

  require "active_support/cache/#{store}"
  TinyGit.persistent_cache = ActiveSupport::Cache.lookup_store(store, *Array(params))
  TinyGit.persistent_cache.logger = ActionController::Base.logger
end
