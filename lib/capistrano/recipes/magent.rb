Capistrano::Configuration.instance.load do
  _cset(:magent_queue, :default)  
  _cset(:magent_grace_time, 120)  
#  _cset(:magent_local_config) { "#{templates_path}/magent.bluepill.erb" }  
#  _cset(:magent_remote_config) { "#{shared_path}/config/pills/magent.pill" } 

  _cset(:magent_bin, "cd #{current_path} && /usr/bin/env RAILS_ENV=#{rails_env} bundle exec magent")
  
  _cset(:magent_log_path){ File.join(shared_path, "log") }
  _cset(:magent_log_file){ File.join(magent_log_path, "magent.log") }
  _cset(:magent_pid_path, "#{pids_path}")  
  _cset(:magent_pid_file){ File.join(magent_pid_path, "magent.#{magent_queue}-#{Socket.gethostname.split('.')[0]}.pid") }
 
  namespace :magent do
    desc "Configure magent pill"
    task :setup, :roles => :app do
      set(:db_host) { Capistrano::CLI.ui.ask("Enter #{environment} database host:") { |q|q.default = "localhost" } }
      set(:db_port) { Capistrano::CLI.ui.ask("Enter #{environment} database port:", Integer){ |q| q.default = 27017 } }
      set(:db_user) { Capistrano::CLI.ui.ask "Enter #{environment} database username:" }
      set(:db_pass) { Capistrano::CLI.password_prompt "Enter #{environment} database password:" }
      set(:db_safe_mode) { Capistrano::CLI.ui.agree "Enable safe mode on #{environment} database? [Yn]:" }
      
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
#      generate_config(magent_local_config, magent_remote_config)      
    end

#    desc "Init magent with bluepill"
#    task :init, :roles => :app do
#      run "bluepill load #{magent_remote_config} --no-privileged"
#    end

    desc "Start magent with bluepill"
    task :start, :roles => :app do
#      run "bluepill magent start --no-privileged"
      run "#{magent_bin} -d -Q #{magent_queue} -l #{magent_log_path} -P #{magent_pid_path} start"
    end

    desc "Restart magent with bluepill"
    task :restart, :roles => :app do
#      run "bluepill magent restart --no-privileged"
      run "#{magent_bin} -d -Q #{magent_queue} -l #{magent_log_path} -P #{magent_pid_path} restart"
    end

    desc "Stop magent with bluepill"
    task :stop, :roles => :app do
#      run "bluepill magent stop --no-privileged"
      run "#{magent_bin} -d -Q #{magent_queue} -l #{magent_log_path} -P #{magent_pid_path} stop"
    end

#    desc "Display the bluepill status"
#    task :status, :roles => :app do
#      run "bluepill magent status --no-privileged"
#      run "#{magent_bin} -d -Q #{magent_queue} -l #{shared_path}/log -P #{magent_pid_path} status"
#    end

    desc "Stop magent and quit bluepill"
    task :quit, :roles => :app do
      run "#{magent_bin} -d -Q #{magent_queue} -l #{magent_log_path} -P #{magent_pid_path} stop"
      run "#{magent_bin} -d -Q #{magent_queue} -l #{magent_log_path} -P #{magent_pid_path} quit"
#     run "bluepill magent stop --no-privileged"
#      run "bluepill magent quit --no-privileged"
    end
  end
  

  
end