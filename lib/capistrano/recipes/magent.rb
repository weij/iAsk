Capistrano::Configuration.instance.load do
  _cset(:magent_queue, :default)  
  _cset(:magent_grace_time, 120)  
  _cset(:magent_local_config) { "#{templates_path}/magent.bluepill.erb" }  
  _cset(:magent_remote_config) { "#{shared_path}/config/pills/magent.pill" } 

  namespace :magent do
    desc "Configure magent pill"
    task :setup, :roles => :app do
      db_config = ERB.new <<-EOF
defaults: &defaults
  host: #{db_host}
  port: #{db_port}
  <% if db_user && !db_user.empty? %>
  username: #{db_user}
  password: #{db_pass}
  <% end %>
  autocreate_indexes: false
  allow_dynamic_fields: true
  include_root_in_json: false
  parameterize_keys: true
  persist_in_safe_mode: #{db_safe_mode}
  raise_not_found_error: true
  reconnect_time: 3
development:
  <<: *defaults
  database: shapado-magent-development
  websocket_channel: magent.websocket

test:
  database: shapado-magent-test

production:
  <<: *defaults
  database: shapado-magent-production
  websocket_channel: magent.websocket
      EOF
      put db_config.result(binding), "#{shared_path}/config/magent.yml"
      generate_config(magent_local_config, magent_remote_config)      
    end

    desc "Init magent with bluepill"
    task :init, :roles => :app do
      run "bluepill load #{magent_remote_config} --no-privileged"
    end

    desc "Start magent with bluepill"
    task :start, :roles => :app do
      run "bluepill magent start --no-privileged"
    end

    desc "Restart magent with bluepill"
    task :restart, :roles => :app do
      run "bluepill magent restart --no-privileged"
    end

    desc "Stop magent with bluepill"
    task :stop, :roles => :app do
      run "bluepill magent stop --no-privileged"
    end

    desc "Display the bluepill status"
    task :status, :roles => :app do
      run "bluepill magent status --no-privileged"
    end

    desc "Stop magent and quit bluepill"
    task :quit, :roles => :app do
      run "bluepill magent stop --no-privileged"
      run "bluepill magent quit --no-privileged"
    end
  end
  

  
end