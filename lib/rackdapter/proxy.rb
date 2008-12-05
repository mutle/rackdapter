module Rackdapter
  
  class InboundProxyConnection < EventMachine::Connection
    
    def initialize(*args)
      @app = args.first
      super
    end
    
    def client_connection=(con)
      @request = con
    end
    
    def post_init
      host,port = "127.0.0.1", @app.next_port
      EventMachine::connect host, port, OutboundProxyConnection, self
      @receive_buffer = ""
      @connected = false
    end
    
    def receive_data(data)
      @receive_buffer << data
      if @connected
        send data
      else
        if @request
          @connected = true
          send @receive_buffer
        end
      end
    end
    
    def send(data)
      # puts "sending to client: #{data}\n---\n"
      @request.send_data(data)
    end
    
    def close
      close_connection_after_writing
    end
    
    def unbind
      close_connection
    end
    
  end
  
  class OutboundProxyConnection < EventMachine::Connection
    
    def initialize(*args)
      @response = args.first
      @response.client_connection = self
      super
    end
    
    def post_init
      @response_buffer = ""
    end
    
    def receive_data(data)
      # puts "sending to proxy: #{data.inspect}\n---\n"
      @response_buffer << data
      @response.send_data(data)
    end
    
    def unbind
      @response.close
    end
    
  end
  
  class Proxy
    
    include Rackdapter::Configuration
    
    def config
      Rackdapter.config.apps[:proxy]
    end
    
    def logger
      unless @logger
        @logger = Logger.new(config['log'] || STDOUT)
        @logger.level = Logger::INFO
      end
      @logger
    end
    
    def log(message)
      logger.info message
    end
    
    def initialize(config_path)
      configure(config_path)
      log "Starting proxy server with configuration at #{config_path}"
      start
    end
    
    def start
      load_apps
      EventMachine::run {
        apps.each do |name,app|
          host,port = "0.0.0.0", app.port
          if port && port > 0
            log "Starting proxy at #{host}:#{port}"
            EventMachine::start_server host, port, InboundProxyConnection, app
          end
        end
      }
    end    
    
  end
  
end