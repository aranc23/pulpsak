require "pulpsak/version"
require 'pulp_rpm_client'
require 'pulpcore_client'
require 'yaml'

module Pulpsak
  class Error < StandardError; end
  @@config = {
  }
  config_yaml = ''
  if ENV.has_key?('XDG_CONFIG_HOME')
    config_yaml = File.join(ENV['XDG_CONFIG_HOME'],'pulpsak','config.yaml')
  elsif ENV.has_key?('HOME')
    config_yaml = File.join(ENV['HOME'],'.config','pulpsak','config.yaml')
  end
  if File.exists?(config_yaml)
    @@config = YAML.load_file(config_yaml)
  else
    puts "#{config_yaml} does not exist, using defaults"
  end
 
  PulpcoreClient.configure do |config|
    config_data = {}
    if @@config.has_key?('pulpcore')
      config_data = @@config['pulpcore']
    elsif @@config.has_key?('default')
      config_data = @@config['default']
    end
    config_data.each do |key, value|
      config.instance_variable_set("@#{key}".to_sym, value)
    end
  end
  PulpRpmClient.configure do |config|
    config_data = {}
    if @@config.has_key?('pulp_rpm')
      config_data = @@config['pulp_rpm']
    elsif @@config.has_key?('default')
      config_data = @@config['default']
    end
    config_data.each do |key, value|
      config.instance_variable_set("@#{key}".to_sym, value)
    end
  end

  def self.repository_inspect(href)
    api_instance = PulpRpmClient::RepositoriesRpmApi.new
    return api_instance.read(href)
  end
  def self.repository_version_inspect(href)
    api_instance = PulpRpmClient::RepositoriesRpmVersionsApi.new
    return api_instance.read(href)
  end
  def self.repository_inspect_by_name(name)
    api_instance = PulpRpmClient::RepositoriesRpmApi.new
    api_instance.list.results.each do |repo|
      if repo.name == name
        return repository_inspect(repo.pulp_href)
      end
    end
    return nil
  end
  def self.remote_inspect(href)
    api_instance = PulpRpmClient::RemotesRpmApi.new
    return api_instance.read(href)
  end
  def self.remote_inspect_by_name(name)
    api_instance = PulpRpmClient::RemotesRpmApi.new
    api_instance.list.results.each do |remote|
      if remote.name == name
        return remote_inspect(remote.pulp_href)
      end
    end
    return nil
  end
  def self.distribution_inspect_by_name(name)
    api_instance = PulpRpmClient::DistributionsRpmApi.new
    api_instance.list.results.each do |dist|
      if dist.name == name
        return dist
      end
    end
    return nil
  end
  def self.task_inspect(href)
    api_instance = PulpcoreClient::TasksApi.new
    return api_instance.read(href)
  end
  def self.wait_on_task(href,sleep_time: 3, spacer: '.', final: "\n")
    api = PulpcoreClient::TasksApi.new
    last_message = ''
    while true
      i = Pulpsak.task_inspect(href)
      if i.state == 'running' or i.state == 'waiting'
        if i.progress_reports.respond_to?(:length) and i.progress_reports.length() > 0
          if last_message != i.progress_reports[-1].message
            last_message = i.progress_reports[-1].message
            print last_message,"\n"
          end
        else
          print spacer
        end
        sleep sleep_time
      else
        break
      end
    end
    print final
    task = Pulpsak.task_inspect(href)
    return task
  end
  def self.find_existing_publication(pub_opts)
    pub_api = PulpRpmClient::PublicationsRpmApi.new
    existing_publication = nil
    if pub_opts.has_key?(:repository_version)
      # if we have a specific version, we can look through all
      # existing publications to avoid creating one, which can be
      # expensive
      pub_api.list.results.each do |pub|
        pub_hash = pub.to_hash
        match = true
        [:metadata_checksum_type,:package_checksum_type,:gpgcheck,:repo_gpgcheck,:repository_version].each do |p|
          if pub_opts[p] != pub_hash[p]
            match = false
            break
          end
        end
        if match
          existing_publication = pub
          break
        end
      end
    end
    return existing_publication
  end
end
