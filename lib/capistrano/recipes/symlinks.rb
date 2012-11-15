Capistrano::Configuration.instance.load do
  # These are set to the same structure in shared <=> latest_release
  _cset :normal_symlinks, %w(config/mongoid.yml config/magent.yml config/auth_providers.yml)  

  # Weird symlinks go somewhere else. Weird.
  _cset :weird_symlinks, { 'bundle' => 'vendor/bundle' }  

  _cset(:auth_local_config) { File.join(templates_path, "auth_providers.yml.erb") }  
  _cset(:auth_remote_config) { File.join(shared_path, "config/auth_providers.yml") }  
  
  namespace :symlinks do
    desc "|capistrano-recipes| Make all the symlinks in a single run"
    task :make, :roles => :app, :except => { :no_release => true } do
      
      generate_config(auth_local_config, auth_remote_config)

      commands = normal_symlinks.map do |path|
        "rm -rf #{latest_release}/#{path} && \
         ln -s #{shared_path}/#{path} #{latest_release}/#{path}"
      end

      commands += weird_symlinks.map do |from, to|
        "rm -rf #{latest_release}/#{to} && \
         ln -s #{shared_path}/#{from} #{latest_release}/#{to}"
      end

      run <<-CMD
        cd #{latest_release} && #{commands.join(" && ")}
      CMD
    end
  end
end