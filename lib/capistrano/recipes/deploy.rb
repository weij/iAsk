Capistrano::Configuration.instance.load do

  namespace :deploy do

    desc "|capistrano-recipes| Destroys everything"
    task :seppuku, :roles => :app, :except => { :no_release => true } do
      run "rm -rf #{current_path}; rm -rf #{shared_path}"
    end
    
    desc "|capistrano-recipes| Uploads your local config.yml to the server"
    task :configure, :roles => :app, :except => { :no_release => true } do
      generate_config('config/config.yml', "#{shared_path}/config/config.yml")
    end
    
  end
end