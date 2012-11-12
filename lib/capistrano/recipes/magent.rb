Capistrano::Configuration.instance.load do
  _cset(:magent_queue, :default)  
  _cset(:magent_grace_time, 120)  
  _cset(:magent_local_config) { "#{templates_path}/magent.bluepill.erb" }  
  _cset(:magent_remote_config) { "#{shared_path}/config/pills/magent.pill" } 

  namespace :magent do
    desc "Configure magent pill"
    task :setup do
      generate_config(magent_local_config, magent_remote_config)
    end

    desc "Init magent with bluepill"
    task :init do
      run "bluepill load #{magent_remote_config} --no-privileged"
    end

    desc "Start magent with bluepill"
    task :start do
      run "bluepill magent start --no-privileged"
    end

    desc "Restart magent with bluepill"
    task :restart do
      run "bluepill magent restart --no-privileged"
    end

    desc "Stop magent with bluepill"
    task :stop do
      run "bluepill magent stop --no-privileged"
    end

    desc "Display the bluepill status"
    task :status do
      run "bluepill magent status --no-privileged"
    end

    desc "Stop magent and quit bluepill"
    task :quit do
      run "bluepill magent stop --no-privileged"
      run "bluepill magent quit --no-privileged"
    end
  end
  

  
end