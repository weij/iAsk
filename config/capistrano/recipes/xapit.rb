Capistrano::Configuration.instance.load do  

  # Defines where the unicorn pid will live.
  set(:xapit_pid) { File.join(pids_path, "xapit.pid") } unless exists?(:xapit_pid)

  set(:xapit_local_yml) { File.join(templates_path, "xapit.yml.erb") }
  set(:xapit_remote_yml) { "#{shared_path}/config/xapit.yml" }
  set(:xapit_local_config) { File.join(templates_path, "xapit.ru.erb") }
  set(:xapit_remote_config) { "#{shared_path}/config/xapit.ru" }
  
  
  def xapit_start_cmd
#    "rackup -E #{rails_env} -P #{xapit_pid} -D #{xapit_remote_config}"
    "rackup --env=#{rails_env} --pid=#{xapit_pid} --daemonize --warn --debug #{xapit_remote_config}"
  end

  def xapit_stop_cmd
    "kill -QUIT `cat #{xapit_pid}`"
  end

  def xapit_restart_cmd
    "kill -USR2 `cat #{xapit_pid}`"
  end

  # Xapit
  #------------------------------------------------------------------------------
  namespace :xapit do
    desc "|capistrano-recipes| Starts xapit directly"
    task :start, :roles => :app do
      run "cd #{current_path} && #{xapit_start_cmd}"
    end

    desc "|capistrano-recipes| Stops xapit directly"
    task :stop, :roles => :app do
      run xapit_stop_cmd
    end

    desc "|capistrano-recipes| Restarts xapit directly"
    task :restart, :roles => :app do
      run xapit_restart_cmd
    end
    
    desc <<-EOF
    |capistrano-recipes| Parses the configuration file through ERB to fetch our variables and \
    uploads the result to #{xapit_remote_config}, to be loaded by whoever is booting \
    up the unicorn.
    EOF
    task :setup, :roles => :app , :except => { :no_release => true } do
      generate_config(xapit_local_config, xapit_remote_config)
      generate_config(xapit_local_yml, xapit_remote_yml)
    end
  end

  after 'deploy:setup' do
    xapit.setup if Capistrano::CLI.ui.agree("Create xapit configuration file? [Yn]")
  end  
end