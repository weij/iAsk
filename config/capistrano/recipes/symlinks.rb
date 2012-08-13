Capistrano::Configuration.instance.load do
  # These are set to the same structure in shared <=> current
  set :normal_symlinks, %w(tmp logs config/mongoid.yml config/auth_providers.yml) unless exists?(:normal_symlinks)

  # Weird symlinks go somewhere else. Weird.
  set :weird_symlinks, { 'bundle' => 'vendor/bundle',
                         'pids' => 'tmp/pids', 
                         'logs'  => 'tmp/logs'} unless exists?(:weird_symlinks)

  set(:auth_local_config) { "#{templates_path}/auth_providers.yml.erb" } unless exists?(:auth_local_config)
  set(:auth_remote_config) { "#{shared_path}/config/auth_providers.yml" } unless exists?(:auth_remote_config)
  
  
  namespace :symlinks do
    desc "|capistrano-recipes| Make all the symlinks in a single run"
    task :make, :roles => :app, :except => { :no_release => true } do
      
      generate_config(auth_local_config, auth_remote_config)

      commands = normal_symlinks.map do |path|
        "rm -rf #{current_path}/#{path} && \
         ln -s #{shared_path}/#{path} #{current_path}/#{path}"
      end

      commands += weird_symlinks.map do |from, to|
        "rm -rf #{current_path}/#{to} && \
         ln -s #{shared_path}/#{from} #{current_path}/#{to}"
      end

      run <<-CMD
        cd #{current_path} && #{commands.join(" && ")}
      CMD
    end
  end
end