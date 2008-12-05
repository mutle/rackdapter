module Rackdapter
  
  class Master
    
    include Rackdapter::Configuration
    
    def initialize(config_path)
      log "Loading rackdapter config at #{config_path}"
      configure(config_path)
      log "Configuration loaded, starting master server"
      start
    end
    
    def start
      load_apps
      run
    end
    
    private
    
    def all_apps(action)
      apps.each do |name, app|
        app.send(action.to_sym)
      end
    end
    
    def run      
      Signal.trap("INT") { all_apps(:stop); exit(0) }
      Signal.trap("TERM") { all_apps(:stop); exit(0) }
      Signal.trap("HUP") { all_apps(:restart) }
      EventMachine::run {
        EventMachine::add_timer(5) { all_apps(:ensure_running) }
      }
    end
  end
  
end
