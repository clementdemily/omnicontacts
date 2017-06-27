require "omnicontacts"

module OmniContacts
  class Builder < Rack::Builder
    def initialize(app, &block)
      if rack14? || rack2?
        super
      else
        @app = app
        super(&block)
        @ins << @app
      end
    end

    def rack14?
      v = Rack.release.split('.')
      v[0].to_i >= 1 || v[1].to_i >= 4
    end

    def rack2?
      Rack.release.start_with? '2.'
    end

    def importer importer, *args
      middleware = OmniContacts::Importer.const_get(importer.to_s.capitalize)
      use middleware, *args
    rescue NameError
      raise LoadError, "Could not find importer #{importer}."
    end

    def call env
      to_app.call(env)
    end
  end
end
