require "rails_same_site_cookie/version"
require "rails_same_site_cookie/configuration"
require "rails_same_site_cookie/railtie" if defined?(Rails)

module RailsSameSiteCookie
  class Error < StandardError; end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.use_same_site_cookie?(env)
    configuration.send_same_site_none?(env) &&
      UserAgentChecker.new(env['HTTP_USER_AGENT'], ssl: Rack::Request.new(env).ssl?).send_same_site_none?
  end
end
