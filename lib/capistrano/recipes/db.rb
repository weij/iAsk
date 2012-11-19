require 'erb'

Capistrano::Configuration.instance.load do
  
  _cset(:mongo_daemon) { "/usr/bin/env mongod" } 
  _cset(:mongo_configpath) { "/opt/etc" }
  _cset(:mongo_dbpath) { "/opt/var/db/mongo/master" } 
  _cset(:mongo_pidpath) { "/opt/var/run/mongo" }
  _cset(:mongo_pid) { File.join(mongo_pidpath, "master.pid") }
  _cset(:mongo_keyfilepath) { "/opt/var/db/mongo/key" } 
  _cset(:mongo_keyfile) { File.join(mongo_keyfilepath, "master") }  
  _cset(:mongo_logpath) { "/opt/var/log/mongo" }
  _cset(:mongo_log) { File.join(mongo_logpath, "master.log") }
  _cset(:mongo_local_config) { File.join(templates_path, "mongodb.conf.erb") }  
  _cset(:mongo_remote_config) { File.join(mongo_configpath, "master.conf") }
         
  _cset(:redis_pid) { File.join(pids_path, "redis.pid") }
  _cset(:redis_daemon) { "/usr/bin/env redis-server" }
  _cset(:redis_local_config) { File.join(templates_path, "redis.conf.erb") } 
  _cset(:redis_remote_config) { File.join(shared_path, "config/redis.conf") }  
  
  def redis_start_cmd
    "start-stop-daemon --start --quiet --umask 007 --pidfile #{redis_pid} --chuid #{user}:#{group} "\
    "--exec #{redis_daemon} -- #{redis_remote_config}"
  end
  
  def redis_stop_cmd
    "start-stop-daemon --stop --retry 10 --quiet --oknodo --pidfile #{redis_pid} --exec #{redis_daemon}"
  end
  
  def mongodb_start_cmd
    "start-stop-daemon --background --start --quiet --pidfile #{mongo_pid} --make-pidfile "\
    "--chuid #{user}:#{group} --exec #{mongo_daemon} -- --config #{mongo_remote_config} run"
  end
  
  def mongodb_stop_cmd
    "start-stop-daemon --stop --quiet --pidfile #{mongo_pid} --user #{user} --exec #{mongo_daemon}"
  end
    
    
  namespace :db do    
    
    desc "|capistrano-recipes| setup the redis"
    task :bootstrap, :roles => :app do
      run "cd #{current_path} && /usr/bin/env RAILS_ENV=#{rails_env} bundle exec rake bootstrap"
    end
    
    namespace :redis do
      desc "|capistrano-recipes| setup the redis"
      task :setup, :roles => :app do
        generate_config(redis_local_config, redis_remote_config)   
      end
      
      desc "|capistrano-recipes| start the redis"
      task :start, :roles => :app do
        run redis_start_cmd do |ch, stream, out|
          puts out
        end
      end
      
      desc "|capistrano-recipes| stop the redis"
      task :stop, :roles => :app do
        run redis_stop_cmd do |ch, stream, out|
          puts out
        end
      end
      
      desc "|capistrano-recipes| restart the redis"
      task :restart, :roles => :app do
        redis.stop
        redis.start
      end
    end
    
    namespace :mongodb do      
      desc "|capistrano-recipes| Create mongoid.yml in shared path with settings for current stage and test env"
      task :setup_mongoid, :roles => :app do
        connections = []
        while Capistrano::CLI.ui.agree("Do you want to added more host? [Yn]") do
          host = Capistrano::CLI.ui.ask("Enter #{environment} database host:") {|q|q.default = "localhost"} 
          port = Capistrano::CLI.ui.ask("Enter #{environment} database port:", Integer){|q| q.default = 27017 } 
          connections << [host, port]
        end
        set(:db_user) { Capistrano::CLI.ui.ask "Enter #{environment} database username:" }
        set(:db_pass) { Capistrano::CLI.password_prompt "Enter #{environment} database password:" }
        set(:db_safe_mode) { Capistrano::CLI.ui.agree "Enable safe mode on #{environment} database? [Yn]:" }
        
        db_config = ERB.new <<-EOF
defaults: &defaults
  hosts: <% connections.each do|conn| %>
    - 
      - <%= conn[0] %>
      - <%= conn[1] %><% end %>
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
  database: #{application}-development

test:
  <<: *defaults
  database: #{application}-test

production:
  <<: *defaults
  database: #{application}-production
        EOF
                
        put db_config.result(binding), "#{shared_path}/config/mongoid.yml"
      end
      
      desc "|capistrano-recipes| setup mongo db path and mongo conf file"
      task :setup, :roles => :db, :only => { :primary => true }  do
        [mongo_logpath, mongo_dbpath, mongo_pidpath, mongo_configpath, mongo_keyfilepath].each do |path|
          run "if [ ! -d '#{path}' ]; then mkdir -p #{path}; fi;"
        end
        run "echo 'This is master key file' > #{mongo_keyfile} && chmod 600 #{mongo_keyfile}"
        generate_config(mongo_local_config, mongo_remote_config, :db) 
      end
      
      desc "|capistrano-recipes| start the mongodb"
      task :start, :roles => :db, :only => { :primary => true } do
        run mongodb_start_cmd do |ch, stream, out|
          puts out
        end
      end      
      
      desc "|capistrano-recipes| stop the mongodb"
      task :stop, :roles => :db, :only => { :primary => true } do
        run mongodb_stop_cmd do |ch, stream, out|
          puts out
        end
      end
      
      desc "|capistrano-recipes| stop the mongodb"
      task :restart, :roles => :db, :only => { :primary => true } do
        mongodb.stop
        mongodb.start
      end
      
      desc <<-EOF
      |capistrano-recipes| Performs a compressed database dump. \
      WARNING: This locks your tables for the duration of the mongodump.
      Don't run it madly!
      EOF
      task :dump, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        run "mongodump #{auth_options} -h #{db_host} --port #{db_port} -d #{db_name} -o #{db_backup_path}" do |ch, stream, out|
          puts out
        end
      end

      desc "|capistrano-recipes| Restores the database from the latest compressed dump"
      task :restore, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        run "mongorestore #{auth_options} --drop -d #{db_name} #{db_backup_path}/#{db_name}" do |ch, stream, out|
          puts out
        end
      end

      desc "|capistrano-recipes| Downloads the compressed database dump to this machine"
      task :fetch_dump, :roles => :db, :only => { :primary => true } do
        prepare_from_yaml
        download db_remote_backup, db_local_file, :via => :scp, :recursive => true
      end

      def auth_options
        if db_user && db_pass
          "-u #{db_user} -p #{db_pass}"
        end
      end

      # Sets database variables from remote database.yaml
      def prepare_from_yaml
        set(:db_backup_path) { "#{shared_path}/backup/" }

        set(:db_local_file)  { "tmp/" }
        set(:db_user) { db_config[rails_env.to_s]["username"] }
        set(:db_pass) { db_config[rails_env.to_s]["password"] }
        set(:db_host) { db_config[rails_env.to_s]["host"] }
        set(:db_port) { db_config[rails_env.to_s]["port"] }
        set(:db_name) { db_config[rails_env.to_s]["database"] }

        set(:db_remote_backup) { "#{db_backup_path}/#{db_name}" }
      end

      def db_config
        @db_config ||= fetch_db_config
      end

      def fetch_db_config
        require 'yaml'
        file = capture "cat #{shared_path}/config/mongoid.yml"
        db_config = YAML.load(file)
      end
    end
  end


end