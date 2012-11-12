Capistrano::Configuration.instance.load do
  
  set(:websocket_remote_config) { "#{shared_path}/config/pills/websocket.pill"}
  
  namespace :websocket do
    desc "setup websocket pill"
    task :setup do
      generate_config("#{File.dirname(__FILE__)}/pills/websocket.pill.erb", websocket_remote_config)
    end

    desc "Init websocket with bluepill"
    task :init do
      run "bluepill load #{websocket_remote_config} --no-privileged"
    end

    desc "Start websocket with bluepill"
    task :start do
      run "bluepill websocket start --no-privileged"
    end

    desc "Restart websocket with bluepill"
    task :restart do
      websocket.stop
      websocket.start
    end

    desc "Stop websocket with bluepill"
    task :stop do
      run "bluepill websocket stop --no-privileged"
    end

    desc "Display the bluepill status"
    task :status do
      run "bluepill websocket status --no-privileged"
    end

    desc "Stop websocket and quit bluepill"
    task :quit do
      run "bluepill websocket stop --no-privileged"
      run "bluepill websocket quit --no-privileged"
    end
  end
  
end