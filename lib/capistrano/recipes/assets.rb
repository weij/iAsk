Capistrano::Configuration.instance.load do

  set :asset_env, "RAILS_GROUPS=assets"
  set :assets_prefix, "assets"
  _cset :asset_packager, "jammit"  
  _cset :assets_role, [:app]
  
  namespace :assets do
    
    task :precompile, :roles => assets_role, :except => { :no_release => true }   do
      run "cd #{latest_release} && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
    end
    
    desc "Compile Assets with compass"
    task :compass, :roles => assets_role, :except => { :no_release => true }  do
      run "cd #{latest_release} && bundle exec compass compile; true"
    end

    desc "Package assets"
    task :package, :roles => assets_role, :except => { :no_release => true }  do
      run "cd #{latest_release} && bundle exec #{asset_packager}; true"
    end
    
    task :reload_theme, :roles => assets_role, :except => { :no_release => true } do
      run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} setup:default_theme"
    end
    
  end
end