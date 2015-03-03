class Twilio
  def account_id
    ENV['TWILIO_ACCOUNT_ID']
  end

  def account_secret
    ENV['TWILIO_ACCOUNT_SECRET']
  end

  def account_sms_number
    ENV['TWILIO_SMS_NUMBER']
  end

  def api_url
    "https://api.twilio.com/2010-04-01/Accounts/#{ account_id }/Messages.json"
  end

  def send_sms(to, body)
    uri = URI.parse(api_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    header = { 'Content-Type' => 'application/json' }

    req = Net::HTTP::Post.new(uri.path, header)
    req.basic_auth(account_id, account_secret)

    req.form_data = { From: account_sms_number, To: to, Body: body }
    JSON[http.start { |http_client| http_client.request(req) }.body]
  end
end
