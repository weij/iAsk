set :application, "iask"
set :asset_packager, "jammit"
set :deploy_to, "/opt/var/deploy/iask"

set :user, "james"
set :password, "my@830507"
set :use_sudo, false

#sudo: no tty present and no askpass program specified
default_run_options[:pty] = true

set :group, "james"

set :default_environment, {
  'GEM_HOME' => '/usr/local/rvm/gems/ruby-1.9.3-p194',
  'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p194:/usr/local/rvm/gems/ruby-1.9.3-p194@global',
  'PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p194/bin:/usr/local/rvm/gems/ruby-1.9.3-p194@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p194/bin:/usr/local/rvm/bin:$PATH',
  'RUBY_VERSION' => 'ruby-1.9.3-p194'
}

task :production do |t|
  set :repository, "git@github.com:birdnest/iAsk.git"
  set :branch, "master"
  set :rails_env, :production
  set :unicorn_workers, 1  

  set :scm, :git
  
  role :web, "10.211.55.9"
  role :app, "10.211.55.9"
  role :db,  "10.211.55.9", :primary => true
end

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "echo '#{`git describe`}' > #{current_path}/public/version.txt"
    run "cd #{current_path} && ln -sf #{shared_path}/config/auth_providers.yml #{current_path}/config/auth_providers.yml"

    assets.compass
    assets.package

    #magent.restart
#    bluepill.restart

    run "rm -rf #{current_path}/tmp/cache/*"
  end
end

#######################################################require 'ricodigo_capistrano_recipes'####################

require File.expand_path("../capistrano/tasks", __FILE__)

#######################################################require 'ricodigo_capistrano_recipes'########################

set(:websocket_remote_config) { "#{shared_path}/config/pills/websocket.pill"}
namespace :websocket do
  desc "setup websocket pill"
  task :setup do
    generate_config("#{File.dirname(__FILE__)}/pills/websocket.pill.erb", websocket_remote_config)
  end

  desc "Init websocket with bluepill"
  task :init do
    rvmsudo "bluepill load #{websocket_remote_config}"
  end

  desc "Start websocket with bluepill"
  task :start do
    rvmsudo "bluepill websocket start"
  end

  desc "Restart websocket with bluepill"
  task :restart do
    websocket.stop
    websocket.start
  end

  desc "Stop websocket with bluepill"
  task :stop do
    rvmsudo "bluepill websocket stop"
  end

  desc "Display the bluepill status"
  task :status do
    rvmsudo "bluepill websocket status"
  end

  desc "Stop websocket and quit bluepill"
  task :quit do
    rvmsudo "bluepill websocket stop"
    rvmsudo "bluepill websocket quit"
  end
end

