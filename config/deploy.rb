set :application, "myask"
set :asset_packager, "jammit"
set :deploy_to, "/opt/var/deploy/myask"

set :user, "deploy"
set :password, "123456"
set :use_sudo, false

#sudo: no tty present and no askpass program specified
default_run_options[:pty] = true

set :group, "deploy"

set :ruby_version, 'ruby-1.9.3-p327' 

set :default_environment, {
  'GEM_HOME' => "/usr/local/rvm/gems/#{ruby_version}",
  'GEM_PATH' => "/usr/local/rvm/gems/#{ruby_version}:/usr/local/rvm/gems/#{ruby_version}@global",
  'PATH'     => "/usr/local/rvm/gems/#{ruby_version}/bin:/usr/local/rvm/gems/#{ruby_version}@global/bin:/usr/local/rvm/rubies/#{ruby_version}/bin:/usr/local/rvm/bin:$PATH",
  'RUBY_VERSION' => "#{ruby_version}"
}

task :production do |t|
  set :repository, "git@github.com:birdnest/iAsk.git"
  set :branch, "master"
  set :rails_env, :production
  set :unicorn_workers, 6 

  set :scm, :git
  
  role :web, "10.211.55.9", :no_release => true
  role :app, "10.211.55.6"
  role :db,  "10.211.55.66", :primary => true, :no_release => true
end

namespace :deploy do
  task :start do
  end
  
  task :stop do
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "echo '#{`git describe`}' > #{current_path}/public/version.txt"
#    run "cd #{current_path} && ln -sf #{shared_path}/config/auth_providers.yml #{current_path}/config/auth_providers.yml"

#    assets.compass
#    assets.package

#    magent.restart
#    bluepill.restart
    
#    xapit.restart

#    run "rm -rf #{current_path}/tmp/cache/*"

puts ">>>>>>>>============================<<<<<<<<"
puts "application => #{application}"
puts "repository => #{repository}"
puts "scm => #{scm}"
puts "deploy_via => #{deploy_via}"
puts "deploy_to => #{deploy_to}"
puts "revision => #{revision}"
puts "rails_env => #{rails_env}"
puts "rake => #{rake}"
puts "source => #{source}"
puts "real_revision => #{real_revision}"
puts "strategy => #{strategy}"
puts "release_name => #{release_name}"
puts "version_dir => #{version_dir}"
puts "shared_dir => #{shared_dir}"
puts "shared_children => #{shared_children}"
puts "current_dir => #{current_dir}"
puts "releases_path => #{releases_path}"
puts "shared_path => #{shared_path}"
puts "current_path => #{current_path}"
puts "release_path => #{release_path}"
puts "releases => #{releases}"
puts "current_release => #{current_release}"
puts "previous_release => #{previous_release}"
puts "run_method => #{run_method}"
puts "latest_release => #{latest_release}"
puts ">>>>>>>>============================<<<<<<<<"


  end
end

require File.expand_path("../../lib/capistrano/tasks", __FILE__)

# cap production deploy --dry-run


