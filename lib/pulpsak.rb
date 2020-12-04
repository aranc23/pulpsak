require "pulpsak/version"
require 'pulp_rpm_client'

module Pulpsak
  class Error < StandardError; end
  PulpRpmClient.configure do |config|
    # Configure HTTP basic authorization: basicAuth
    config.username = 'admin'
    config.password = 'testing'
    config.ssl_verify = false
    config.host = 'localhost:8080'
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
end
