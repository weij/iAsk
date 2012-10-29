Capistrano::Configuration.instance.load do
  set(:magent_queue, :default) unless exists?(:magent_queue)
  set(:magent_grace_time, 120) unless exists?(:magent_grace_time)
  set(:magent_local_config) { "#{templates_path}/magent.bluepill.erb" } unless exists?(:magent_local_config)
  set(:magent_remote_config) { "#{shared_path}/config/pills/magent.pill" } unless exists?(:magent_remote_config)

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
  
  after 'deploy:setup' do
    magent.setup if Capistrano::CLI.ui.agree("Create magent configuration file?[Yn]")
  end if is_using('bluepill', :monitorer)
  
end