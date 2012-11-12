Capistrano::Configuration.instance.load do

  # Where your nginx lives. Usually /opt/nginx or /usr/local/nginx for source compiled.
  _cset :nginx_path_prefix, "/opt/etc/nginx" 

  # Path to the nginx erb template to be parsed before uploading to remote
  _cset(:nginx_local_config) { "#{templates_path}/nginx.conf.erb" }  
  
  # Path to where your remote config will reside (I use a directory sites inside conf)
  _cset(:nginx_remote_config) do
    "#{nginx_path_prefix}/conf.d/#{application}.site.conf"
  end  
  
  _cset(:nginx_local_etc) { "#{templates_path}/nginx.etc.erb" }  
  _cset(:nginx_remote_etc) { "#{nginx_path_prefix}/nginx.conf" }  

  _cset(:nginx_daemon) { "/usr/local/sbin/nginx" }  
  _cset(:nginx_pid) { "/opt/var/run/pids/nginx.pid" }  

  # Nginx tasks are not *nix agnostic, they assume you're using Debian/Ubuntu.
  # Override them as needed.
  namespace :nginx do
    desc "|capistrano-recipes| Parses and uploads nginx configuration for this app."
    task :setup, :roles => :web , :except => { :no_release => true } do
      run "if [ ! -d '#{nginx_path_prefix}' ]; then cp -r /etc/nginx/conf #{nginx_path_prefix} && mkdir -p '#{nginx_path_prefix}/conf.d'; fi;"
      set(:nginx_domains) { Capistrano::CLI.ui.ask("Enter #{application} domain names:") {|q|q.default = "#{application}.com"} }
      generate_config(nginx_local_config, nginx_remote_config)      
      generate_config(nginx_local_etc, nginx_remote_etc)
    end

    desc "|capistrano-recipes| Parses config file and outputs it to STDOUT (internal task)"
    task :parse, :roles => :app , :except => { :no_release => true } do
      puts parse_config(nginx_local_config)
    end

    desc "|capistrano-recipes| Restart nginx"
    task :restart, :roles => :app , :except => { :no_release => true } do
      sudo "start-stop-daemon --stop --signal HUP --quiet --pidfile #{nginx_pid} --exec #{nginx_daemon}"
#      sudo "/usr/local/sbin/nginx -s reload -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end

    desc "|capistrano-recipes| Stop nginx"
    task :stop, :roles => :app , :except => { :no_release => true } do
      sudo "start-stop-daemon --stop --quiet --pidfile #{nginx_pid} --exec #{nginx_daemon}"
#      sudo "/usr/local/sbin/nginx -s quit -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end

    desc "|capistrano-recipes| Start nginx"
    task :start, :roles => :app , :except => { :no_release => true } do
      sudo "start-stop-daemon --start --quiet --pidfile #{nginx_pid} --exec "\
      "#{nginx_daemon} -- -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
#      sudo "/usr/local/sbin/nginx -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end

    desc "|capistrano-recipes| Show nginx status"
    task :status, :roles => :app , :except => { :no_release => true } do
      sudo "/usr/local/sbin/nginx -t -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end
  end

end