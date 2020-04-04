require 'rails_same_site_cookie/user_agent_checker'

module RailsSameSiteCookie
  class Middleware
    COOKIE_SEPARATOR = "\n".freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      cookies = headers['Set-Cookie']

      if cookies && cookies.strip != '' && RailsSameSiteCookie.use_same_site_cookie?(env)
        ssl = Rack::Request.new(env).ssl?

        cookies = cookies.split(COOKIE_SEPARATOR)

        cookies.compact.reject { |c| c == '' }.each do |cookie|
          if ssl && cookie !~ /;\s*secure/i
            cookie << '; Secure'
          end

          if cookie !~ /;\s*samesite=/i
            cookie << '; SameSite=None'
          end
        end

        headers['Set-Cookie'] = cookies.join(COOKIE_SEPARATOR)
      end

      [status, headers, body]
    end
  end
end
