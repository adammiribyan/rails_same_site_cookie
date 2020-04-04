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
    regex = configuration.user_agent_regex
    agent = env['HTTP_USER_AGENT']

    return false unless regex.nil? || regex.match(agent)

    UserAgentChecker.new(agent, ssl: Rack::Request.new(env).ssl?).send_same_site_none?
  end
end
