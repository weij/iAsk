set :application, "iask"
set :asset_packager, "jammit"
set :deploy_to, "/opt/var/deploy/myask"

set :user, "deploy"
set :password, "123456"
set :use_sudo, false

#sudo: no tty present and no askpass program specified
default_run_options[:pty] = true

set :group, "deploy"

set :ruby_version, 'ruby-1.9.3-p286' 
set :default_environment, {
  'GEM_HOME' => "/usr/local/rvm/gems/#{ruby_version}",
  'GEM_PATH' => "/usr/local/rvm/gems/#{ruby_version}:/usr/local/rvm/gems/#{ruby_version}@global",
  'PATH'     => "/usr/local/rvm/gems/#{ruby_version}/bin:/usr/local/rvm/gems/#{ruby_version}@global/bin:/usr/local/rvm/rubies/#{ruby_version}/bin:/usr/local/rvm/bin:$PATH",
  'RUBY_VERSION' => "#{ruby_version}"
}

task :production do |t|
  set :repository, "git@github.com:birdnest/iAsk.git"
#  set :branch, "master"
  set :rails_env, :production
  set :unicorn_workers, 6 

  set :scm, :git
  
  set :assets_role, [:app]
  
  role :web, "172.18.6.86", :no_release => true
  role :app, "172.18.6.86"
  role :db,  "172.18.6.80", :primary => true, :no_release => true
end

namespace :deploy do
  task :start do
    db.redis.start
    unicorn.start
    xapit.start
    magent.start
    nginx.start
  end
  
  task :stop do
    db.redis.stop
    unicorn.stop
    xapit.stop
    magent.stop
    nginx.stop
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    db.redis.restart
    unicorn.restart
    xapit.restart
    magent.restart
    run "rm -rf #{current_path}/tmp/cache/*"
  end
end

require File.expand_path("../../lib/capistrano/tasks", __FILE__)

# cap production deploy --dry-run


