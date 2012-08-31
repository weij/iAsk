Capistrano::Configuration.instance.load do
  set :asset_packager, "jammit" unless exists?(:asset_packager)
  set :asset_env, "RAILS_GROUPS=assets"
  set :assets_role, [:web]
  set :assets_prefix, "assets"
  
  after 'deploy:update', 'assets:symlink'
  after 'deploy:update', 'assets:precompile'
  
  namespace :assets do
    desc "Compile Assets with compass"
    task :compass do
      run "cd #{current_path} && bundle exec compass compile; true"
    end

    desc "Package assets"
    task :package do
      run "cd #{current_path} && bundle exec #{asset_packager}; true"
    end
    
    desc <<-DESC
      [internal] This task will set up a symlink to the shared directory \
      for the assets directory. Assets are shared across deploys to avoid \
      mid-deploy mismatches between old application html asking for assets \
      and getting a 404 file not found error. The assets cache is shared \
      for efficiency. If you customize the assets path prefix, override the \
      :assets_prefix variable to match.
    DESC
    task :symlink, :roles => assets_role, :except => { :no_release => true } do
      run <<-CMD
        rm -rf #{current_path}/public/#{assets_prefix} &&
        mkdir -p #{current_path}/public &&
        mkdir -p #{shared_path}/assets &&
        ln -s #{shared_path}/assets #{current_path}/public/#{assets_prefix}
      CMD
    end

    desc <<-DESC
      Run the asset precompilation rake task. You can specify the full path \
      to the rake executable by setting the rake variable. You can also \
      specify additional environment variables to pass to rake via the \
      asset_env variable. The defaults are:

        set :rake,      "rake"
        set :rails_env, "production"
        set :asset_env, "RAILS_GROUPS=assets"
    DESC
    task :precompile, :roles => assets_role, :except => { :no_release => true } do
      run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile"
    end
    
    task :reload_theme, :roles => assets_role, :except => { :no_release => true } do
      run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} setup:default_theme"
    end

    desc <<-DESC
      Run the asset clean rake task. Use with caution, this will delete \
      all of your compiled assets. You can specify the full path \
      to the rake executable by setting the rake variable. You can also \
      specify additional environment variables to pass to rake via the \
      asset_env variable. The defaults are:

        set :rake,      "rake"
        set :rails_env, "production"
        set :asset_env, "RAILS_GROUPS=assets"
    DESC
    task :clean, :roles => assets_role, :except => { :no_release => true } do
      run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:clean"
    end
  end
end