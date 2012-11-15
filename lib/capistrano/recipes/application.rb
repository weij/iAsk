
Capistrano::Configuration.instance.load do
  
  _cset :web_server, :nginx    
  _cset :app_server, :unicorn  
  _cset :application_port, 80  
  
  _cset :application_uses_ssl, false 
#  _cset :application_port_ssl, 443  
  
  _cset :database, :mongodb  
  _cset :rails_env, 'production' 
  
  _cset(:pids_path) { File.join(shared_path, "pids") }  
  
  _cset(:sockets_path){ File.join(shared_path, "sockets/#{application}") }
    
#  _cset :monitorer, 'bluepill' 
  
  set :shared_dirs, %w(config uploads backup bundle sockets db db/mongo db/redis tmp tmp/logs)
 
  namespace :app do
    task :setup, :roles => :app do
      commands = shared_dirs.map do |path|
        "if [ ! -d '#{path}' ]; then mkdir -p #{path}; fi;"
      end
      run "cd #{shared_path}; #{commands.join(' ')}"
    end
  end
  

end