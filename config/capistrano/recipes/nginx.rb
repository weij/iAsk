Capistrano::Configuration.instance.load do

  # Where your nginx lives. Usually /opt/nginx or /usr/local/nginx for source compiled.
  set :nginx_path_prefix, "#{shared_path}/config/nginx" unless exists?(:nginx_path_prefix)

  # Path to the nginx erb template to be parsed before uploading to remote
  set(:nginx_local_config) { "#{templates_path}/nginx.conf.erb" } unless exists?(:nginx_local_config)
  # Path to where your remote config will reside (I use a directory sites inside conf)
  set(:nginx_remote_config) do
    "#{nginx_path_prefix}/conf.d/#{application}.site.conf"
  end unless exists?(:nginx_remote_config)
  
  set(:nginx_local_etc) { "#{templates_path}/nginx.etc.erb" } unless exists?(:nginx_local_etc)
  set(:nginx_remote_etc) { "#{nginx_path_prefix}/nginx.conf" } unless exists?(:nginx_remote_etc)

  # Nginx tasks are not *nix agnostic, they assume you're using Debian/Ubuntu.
  # Override them as needed.
  namespace :nginx do
    desc "|capistrano-recipes| Parses and uploads nginx configuration for this app."
    task :setup, :roles => :app , :except => { :no_release => true } do
      run "if [ ! -d '#{nginx_path_prefix}' ]; then cp -r /opt/etc/nginx/conf #{nginx_path_prefix} && mkdir -p '#{nginx_path_prefix}/conf.d'; fi;"
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
#      sudo "service nginx restart"
      sudo "/usr/local/sbin/nginx -s reload -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end

    desc "|capistrano-recipes| Stop nginx"
    task :stop, :roles => :app , :except => { :no_release => true } do
      sudo "/usr/local/sbin/nginx -s quit -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end

    desc "|capistrano-recipes| Start nginx"
    task :start, :roles => :app , :except => { :no_release => true } do
      sudo "/usr/local/sbin/nginx -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end

    desc "|capistrano-recipes| Show nginx status"
    task :status, :roles => :app , :except => { :no_release => true } do
      sudo "/usr/local/sbin/nginx -t -p #{shared_path}/tmp/ -c #{nginx_remote_etc}"
    end
  end

  after 'deploy:setup' do
    nginx.setup if Capistrano::CLI.ui.agree("Create nginx configuration file? [Yn]")
  end if is_using_nginx
end