class Asana
  class << self
    def api_key
      ENV['ASANA_API_KEY']
    end

    def workspace_id
      ENV['ASANA_WORKSPACE_ID']
    end

    def create_task(name, project_id, follower_ids, notes)
      uri = URI.parse('https://app.asana.com/api/1.0/tasks')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      header = { 'Content-Type' => 'application/json' }

      req = Net::HTTP::Post.new(uri.path, header)
      req.basic_auth(api_key, '')

      req.body = {
        data: {
          workspace: workspace_id,
          name: name,
          notes: notes,
          projects: project_id,
          followers: follower_ids
        }
      }.to_json()

      body = JSON[http.start { |http| http.request(req) }.body]

      if body['errors'] then
        puts "Server returned an error: #{body['errors'][0]['message']}"
      else
        puts "Created task with id: #{body['data']['id']}"
      end
    end
  end
end
