# encoding: utf-8
module WebTranslateIt
  class Project
    
    def self.fetch_info(api_key)
      success = true
      tries ||= 3
      begin
        WebTranslateIt::Connection.new(api_key) do |http|
          request = Net::HTTP::Get.new("/api/projects/#{api_key}.yaml")
          request.add_field("X-Client-Name", "web_translate_it")
          request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          response = http.request(request)
          if response.is_a?(Net::HTTPSuccess)
            return response.body
          else
            puts "An error occured while fetching the project information:"
            puts StringUtil.failure(response.body)
            exit 1
          end
        end
      rescue Timeout::Error
        puts "Request timeout. Will retry in 5 seconds."
        if (tries -= 1) > 0
          sleep(5)
          retry
        else
          success = false
        end
      rescue
        puts $!.inspect
      end
      success
    end
    
    def self.fetch_stats(api_key)
      success = true
      tries ||= 3
      begin
        WebTranslateIt::Connection.new(api_key) do |http|
          request = Net::HTTP::Get.new("/api/projects/#{api_key}/stats.yaml")
          request.add_field("X-Client-Name", "web_translate_it")
          request.add_field("X-Client-Version", WebTranslateIt::Util.version)
          return Util.handle_response(http.request(request), true)
        end
      rescue Timeout::Error
        puts "Request timeout. Will retry in 5 seconds."
        if (tries -= 1) > 0
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end
    
    def self.create_locale(locale_code)
      success = true
      tries ||= 3
      begin
        request = Net::HTTP::Post.new("/api/projects/#{Connection.api_key}/locales")
        request.add_field("X-Client-Name", "web_translate_it")
        request.add_field("X-Client-Version", WebTranslateIt::Util.version)
        request.set_form_data({ 'id' => locale_code }, ';')
        Util.handle_response(Connection.http_connection.request(request), true)
      rescue Timeout::Error
        puts "Request timeout. Will retry in 5 seconds."
        if (tries -= 1) > 0
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end
    
    def self.delete_locale(locale_code)
      success = true
      tries ||= 3
      begin
        request = Net::HTTP::Delete.new("/api/projects/#{Connection.api_key}/locales/#{locale_code}")
        request.add_field("X-Client-Name", "web_translate_it")
        request.add_field("X-Client-Version", WebTranslateIt::Util.version)
        Util.handle_response(Connection.http_connection.request(request), true)
      rescue Timeout::Error
        puts "Request timeout. Will retry in 5 seconds."
        if (tries -= 1) > 0
          sleep(5)
          retry
        else
          success = false
        end
      end
      success
    end
  end
end
