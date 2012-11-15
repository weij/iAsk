Capistrano::Configuration.instance.load do

    # Where your nginx lives. Usually /opt/nginx or /usr/local/nginx for source compiled.
    _cset(:nginx_path_prefix){ File.join(shared_path, "config/nginx") }

    # Path to the nginx erb template to be parsed before uploading to remote
    _cset(:nginx_local_config) { File.join(templates_path, "nginx.conf.erb") } 
    # Path to where your remote config will reside (I use a directory sites inside conf)
    _cset(:nginx_remote_config) { File.join(nginx_path_prefix, "conf.d/#{application}.site.conf") }

    _cset(:nginx_local_etc) { File.join(templates_path, "nginx.etc.erb") } 
    _cset(:nginx_remote_etc) { File.join(nginx_path_prefix, "nginx.conf") }  

    _cset(:nginx_daemon) { "/usr/bin/env nginx" }  
    _cset(:nginx_pid) { File.join(pids_path, "nginx.pid") } 


  # Nginx tasks are not *nix agnostic, they assume you're using Debian/Ubuntu.
  # Override them as needed.
  namespace :nginx do
    desc "|capistrano-recipes| Parses and uploads nginx configuration for this app."
    task :setup, :roles => :web  do
      run "if [ ! -d '#{nginx_path_prefix}' ]; then mkdir -p '#{nginx_path_prefix}/conf.d' && cp -r /usr/local/nginx/conf/* #{nginx_path_prefix}; fi;"
      set(:nginx_domains) { Capistrano::CLI.ui.ask("Enter #{application} domain names:") {|q|q.default = "#{application}.com"} }
      generate_config(nginx_local_config, nginx_remote_config, :web)      
      generate_config(nginx_local_etc, nginx_remote_etc, :web)
    end

    desc "|capistrano-recipes| Parses config file and outputs it to STDOUT (internal task)"
    task :parse, :roles => :web do
      puts parse_config(nginx_local_config)
    end
    
    desc "|capistrano-recipes| Restart nginx"
    task :restart, :roles => :web do
      sudo "start-stop-daemon --stop --signal HUP --quiet --pidfile #{nginx_pid} --exec #{nginx_daemon}"
    end

    desc "|capistrano-recipes| Stop nginx"
    task :stop, :roles => :web do
      sudo "start-stop-daemon --stop --quiet --pidfile #{nginx_pid} --exec #{nginx_daemon}"
    end

    desc "|capistrano-recipes| Start nginx"
    task :start, :roles => :web do
      sudo "start-stop-daemon --start --quiet --pidfile #{nginx_pid} --exec "\
      "#{nginx_daemon} -- -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end

    desc "|capistrano-recipes| Show nginx status"
    task :status, :roles => :web do
      sudo "#{nginx_daemon} -t -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end
  end

end