Capistrano::Configuration.instance.load do
  _cset :asset_packager, "jammit"  
  set :asset_env, "RAILS_GROUPS=assets"
  set :assets_role, [:web]
  set :assets_prefix, "assets"

  
  namespace :assets do
    desc "Compile Assets with compass"
    task :compass do
      run "cd #{current_path} && bundle exec compass compile; true"
    end

    desc "Package assets"
    task :package do
      run "cd #{current_path} && bundle exec #{asset_packager}; true"
    end
    
    task :reload_theme, :roles => assets_role, :except => { :no_release => true } do
      run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} setup:default_theme"
    end
    
  end
end