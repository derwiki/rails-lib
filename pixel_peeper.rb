require 'httparty'

class PixelPeeper
  include HTTParty
  base_uri 'www.pixel-peeper.com'
  default_timeout 1 # hard timeout after 1 second

  def api_key
    ENV['PIXELPEEPER_API_KEY']
  end

  def base_path
    "/rest/?method=list_photos&api_key=#{ api_key }"
  end

  def handle_timeouts
    begin
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout
      {}
    end
  end

  def cache_key(options)
    if options[:camera_id]
      "pixelpeeper:camera:#{ options[:camera_id] }"
    elsif options[:lens_id]
      "pixelpeeper:lens:#{ options[:lens_id] }"
    end
  end

  def handle_caching(options)
    if cached = REDIS.get(cache_key(options))
      JSON[cached]
    else
      yield.tap do |results|
        REDIS.set(cache_key(options), results.to_json)
      end
    end
  end

  def build_url_from_options(options)
    if options[:camera_id]
      "#{ base_path }&camera=#{ options[:camera_id] }"
    elsif options[:lens_id]
      "#{ base_path }&lens=#{ options[:lens_id] }"
    else
      raise ArgumentError, "options must specify camera_id or lens_id"
    end
  end

  def examples(options)
    handle_timeouts do
      handle_caching(options) do
        self.class.get(build_url_from_options(options))['data']['results']
      end
    end
  end
end
