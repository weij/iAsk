Capistrano::Configuration.instance.load do

  # Number of workers (Rule of thumb is 1 per CPU)
  # Just be aware that every worker needs to cache all classes and thus eat some of your RAM.
  _cset :unicorn_workers, 4 

  # Workers timeout in the amount of seconds below, when the master kills it and forks another one.
  _cset :unicorn_workers_timeout, 30  

  # Workers are started with this user/group
  # By default we get the user/group set in capistrano.
  _cset(:unicorn_user, user)    
  _cset(:unicorn_group, group)  

  # The wrapped bin to start unicorn
  # This is necessary if you're using rvm
  _cset :unicorn_bin, "cd #{current_path} && /usr/bin/env RAILS_ENV=#{rails_env} bundle exec unicorn"
  _cset(:unicorn_socket){ File.join(sockets_path, 'unicorn.sock') }

  # Defines where the unicorn pid will live.
  _cset(:unicorn_pid) { File.join(pids_path, "unicorn.pid") }  

  # Our unicorn template to be parsed by erb
  # You may need to generate this file the first time with the generator included in the gem
  set(:unicorn_local_config) { File.join(templates_path, "unicorn.rb.erb") }

  # The remote location of unicorn's config file. Used by god to fire it up
  set(:unicorn_remote_config) { File.join(shared_path, "config/unicorn.rb") }
 
  
  def unicorn_start_cmd
    "#{unicorn_bin} -c #{unicorn_remote_config} -E #{rails_env} -D"
  end

  def unicorn_stop_cmd
    "kill -QUIT `cat #{unicorn_pid}`"
  end

  def unicorn_restart_cmd
    "kill -USR2 `cat #{unicorn_pid}`"
  end

  # Unicorn
  #------------------------------------------------------------------------------
  namespace :unicorn do
    desc "|capistrano-recipes| Starts unicorn directly"
    task :start, :roles => :app do
      run unicorn_start_cmd
    end

    desc "|capistrano-recipes| Stops unicorn directly"
    task :stop, :roles => :app do
      run unicorn_stop_cmd
    end

    desc "|capistrano-recipes| Restarts unicorn directly"
    task :restart, :roles => :app do
      unicorn.stop
      run 'sleep 6'
      unicorn.start
    end
    
    desc "|capistrano-recipes| Restarts unicorn directly"
    task :reload, :roles => :app do
      run unicorn_restart_cmd
    end

    desc <<-EOF
    |capistrano-recipes| Parses the configuration file through ERB to fetch our variables and \
    uploads the result to #{unicorn_remote_config}, to be loaded by whoever is booting \
    up the unicorn.
    EOF
    task :setup, :roles => :app , :except => { :no_release => true } do
      # TODO: refactor this to a more generic setup task once we have more socket tasks.
      sudo "mkdir -p #{sockets_path}"
      run "mkdir -p #{deploy_to}/shared/log/"
      sudo "chown #{user}:#{group} #{sockets_path}"
      sudo "chmod +rw #{sockets_path}"
      
      generate_config(unicorn_local_config, unicorn_remote_config)
    end
  end

end