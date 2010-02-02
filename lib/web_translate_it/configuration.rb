module WebTranslateIt
  class Configuration
    require 'yaml'
    require 'fileutils'
    attr_accessor :api_key, :files, :ignore_locales, :logger
    
    def initialize
      file = File.join(RAILS_ROOT, 'config', 'translation.yml')
      configuration       = YAML.load_file(file)
      self.logger         = logger
      self.api_key        = configuration['api_key']
      self.files          = []
      self.ignore_locales = configuration['ignore_locales'].to_a.map{ |locale| locale.to_s }
      configuration['files'].each do |file_id, file_path|
        self.files.push(TranslationFile.new(file_id, file_path, api_key))
      end
    end
    
    def locales
      WebTranslateIt::Util.http_connection do |http|
        request  = Net::HTTP::Get.new(api_url)
        response = http.request(request)
        if response.code.to_i >= 400 and response.code.to_i < 500
          puts "----------------------------------------------------------------------"
          puts "You API key seems to be misconfigured. It is currently “self.api_key”."
          puts "Change it in RAILS_ROOT/configuration/translation.yml."
        else
          response.body.split
        end
      end
    end
    
    def api_url
      "/api/projects/#{api_key}/locales"
    end
    
    def logger
      if defined?(Rails.logger)
        Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      end
    end
  end
end
