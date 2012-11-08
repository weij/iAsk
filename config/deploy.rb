set :application, "iask"
set :asset_packager, "jammit"
set :deploy_to, "/opt/var/deploy/iask"

set :user, "deploy"
set :password, "123456"
set :use_sudo, false

#sudo: no tty present and no askpass program specified
default_run_options[:pty] = true

set :group, "deploy"

set :default_environment, {
  'GEM_HOME' => '/usr/local/rvm/gems/ruby-1.9.3-p286',
  'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p286:/usr/local/rvm/gems/ruby-1.9.3-p286@global',
  'PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p286/bin:/usr/local/rvm/gems/ruby-1.9.3-p286@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p286/bin:/usr/local/rvm/bin:$PATH',
  'RUBY_VERSION' => 'ruby-1.9.3-p286'
}

task :production do |t|
  set :repository, "git@github.com:birdnest/iAsk.git"
  set :branch, "deploy"
  set :rails_env, :production
  set :unicorn_workers, 6 

  set :scm, :git
  
  role :web, "172.18.6.86"
  role :app, "172.18.6.86"
  role :redis, "172.18.6.86"
  role :db,  "172.18.6.80", :primary => true
end

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "echo '#{`git describe`}' > #{current_path}/public/version.txt"
    run "cd #{current_path} && ln -sf #{shared_path}/config/auth_providers.yml #{current_path}/config/auth_providers.yml"

    assets.compass
    assets.package

    magent.restart
    bluepill.restart
    
#    xapit.restart

    run "rm -rf #{current_path}/tmp/cache/*"
  end
end

require File.expand_path("../../lib/capistrano/tasks", __FILE__)


