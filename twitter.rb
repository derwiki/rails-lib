require 'oauth/consumer'
require 'timeout'

class Twitter
  STATUS_UPDATE_URL = 'https://api.twitter.com/1.1/statuses/update.json'.freeze
  LISTS_URL = 'https://api.twitter.com/1.1/lists/list.json'.freeze
  LIST_MEMBERS_URL =
    'https://api.twitter.com/1.1/lists/members.json?list_id=%s'.freeze
  RATE_LIMIT_URL =
    'https://api.twitter.com/1.1/application/rate_limit_status.json'.freeze

  def handle_timeouts(duration = 1)
    Timeout.timeout(duration) do
      begin
        yield
      rescue Timeout::Error
        nil
      end
    end
  end

  def access_token
    handle_timeouts do
      consumer =
        OAuth::Consumer.new ENV['TWITTER_KEY'],
                            ENV['TWITTER_SECRET'],
                            site: 'https://api.twitter.com',
                            request_token_path: '/oauth/request_token',
                            access_token_path: '/oauth/access_token',
                            authorize_path: '/oauth/authorize',
                            scheme: :header

      OAuth::AccessToken.from_hash(
        consumer,
        oauth_token: ENV['TWITTER_CONSUMER_KEY'],
        oauth_token_secret: ENV['TWITTER_CONSUMER_SECRET']
      )
    end
  end

  def tweet(status)
    Rails.logger.info "lib/twitter#tweet #{ status }"
    access_token.post(STATUS_UPDATE_URL, status: status).body
  end

  def lists
    return @_twitter_lists if @_twitter_lists
    @_twitter_lists = JSON[access_token.get(LISTS_URL).body].freeze
  end

  def handles_from_list(list_id)
    @_handles_from_list ||= {}
    return @_handles_from_list[list_id] if @_handles_from_list[list_id]

    resp = JSON[access_token.get(LIST_MEMBERS_URL % list_id).body]
    @_handles_from_list[list_id] =
      resp['users'].map { |user| user['screen_name'] }
  end

  def rate_limits
    JSON[access_token.get(RATE_LIMIT_URL).body]
  end

  def blast(list_id, status)
    handles_from_list(list_id).each do |handle|
      tweet "@#{ handle } #{ status }"
    end
  end

  def list_ids
    lists.map do |list|
      puts "#{ list['id'] } : #{ list['name'] }"
      list['id'].to_i
    end.freeze
  end
end
