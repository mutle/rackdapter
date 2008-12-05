require 'yaml'

module Rackdapter
  
  class << self
    attr_accessor :config_path
  end
  
  def self.config
    @config ||= Config.new(@config_path)
  end
  
  class Config
    
    attr_accessor :apps, :log
    
    def initialize(path='')
      @apps = {}
      config = YAML.load(File.read(path))
      if config
        config.each do |k,v|
          @apps[k.to_sym] = v
        end
        @apps[:proxy] ||= {}
        @apps[:proxy].merge!("type" => "proxy", "instances" => 1, "base_port" => 0)
      end
    end
    
  end
  
  module Configuration
    def configure(config_path)
      Rackdapter.config_path = config_path
      Rackdapter.config
    end
    
    def log(message)
      puts message
    end
    
    def config
      Rackdapter.config
    end
    
    def load_apps
      Rackdapter.config.apps.each do |name,app|
        apps[name] = Application.new(app.merge(:name => name))
      end
    end
    
    def apps
      @apps ||= {}
    end
  end
  
end