module Rackdapter
  
  class Application
    attr_accessor :name, :path, :environment, :backend, :port, :balancer, :base_port, :instances, :type, :log
    
    def initialize(options={})
      options.each do |k,v|
        send("#{k.to_s}=".to_sym, v)
      end
      @app_instances = {}
      ports.each do |port|
        @app_instances[port] = ApplicationInstance.new(self, port)
      end
    end
    
    def app_instances
      @app_instances
    end
    
    def next_port
      @balancer ||= ProxyBalancer.new(ports)
      @balancer.next_port
    end
    
    def ports
      return @ports if @ports
      @ports = []
      instances.times do |i|
        @ports << base_port + i
      end
      @ports
    end
    
    def all_instances(&block)
      @app_instances.each do |port,instance|
        instance.send(:instance_eval, &block)
      end
    end
    
    %w(ensure_running start stop restart).each do |action|
      eval <<-RUBY
        def #{action}
          all_instances { #{action} }
        end
      RUBY
    end
  end    
  
  class ProxyBalancer
    def initialize(ports)
      @ports = ports
      @seq = 0
    end
    
    def next_port
      port = @ports[@seq]
      @seq = @seq + 1
      @seq = 0 if @seq >= @ports.size
      port
    end
  end
  
  def self.app_options(app, port, options)
    log = app.log.gsub(/<port>/, port.to_s).gsub(/<environment>/, app.environment)
    opts = []
    options.each do |k,v|
      unless v.blank?
        opts << "-#{k.to_s}"
        opts << v.to_s
      end
    end
    opts
  end
  
  module RailsBackend
    def self.spawn(app, port)
      Dir.chdir(app.path)
      options = Rackdapter.app_options(app, port, "e" => app.environment, "p" => port, "c" => File.expand_path(app.path))
      exec "ruby", "/usr/bin/mongrel_rails", "start", *options
    end
  end
  
  module MerbBackend
    def self.spawn(app, port)
      Dir.chdir(app.path)
      options = Rackdapter.app_options(app, port, "e" => app.environment, "p" => port, "n" => app.name, "m" => File.expand_path(app.path))
      exec "ruby", "/usr/bin/merb", *options
    end
  end
  
  module ProxyBackend
    def self.spawn(application, port=nil)
      exec "ruby", File.join(File.dirname(__FILE__), '../../bin/rackdapter_proxy'), Rackdapter.config_path
    end
  end
  
  class ApplicationInstance
    
    def initialize(application, port)
      @application = application
      @port = port
      @backend = case @application.type
      when "merb"
        MerbBackend
      when "rails"
        RailsBackend
      when "proxy"
        ProxyBackend
      end
    end
    
    def ensure_running
      start
    end
    
    def start
      return if running?
      @pid = fork do
        @backend.spawn(@application, @port)
      end
      puts "Starting #{@application.name}:#{@port} with pid #{@pid}"
      Process.detach(@pid)
    end
    
    def stop
      if running?
        puts "Stopping #{@application.name}:#{@port}"
        begin
          Process.kill("TERM", @pid)
        rescue
          puts "Process #{@pid} not found"
        end
        @pid = nil
      end
    end
    
    def restart
      puts "Initiating restart of #{@application.name}:#{@port}"
      stop
      start
    end
    
    def running?
      return false unless @pid
      found = false
      `ps`.each_line do |line|
        if line =~ /(^| )(#{@pid}) /
          found = true
          break
        end
      end
      found
    end    
  end
  
end