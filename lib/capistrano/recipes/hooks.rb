# Common hooks for all scenarios.
Capistrano::Configuration.instance.load do
  
  after 'deploy:setup' do
    app.setup    
    bundler.setup if Capistrano::CLI.ui.agree("Do you need to install the bundler gem? [Yn]")
  end
  
  after "deploy:setup" do
    db.mongodb.setup_mongoid if Capistrano::CLI.ui.agree("Create mongoid.yml in app's shared path? [Yn]")
    db.mongodb.setup if Capistrano::CLI.ui.agree("Do you want to generate mongo.conf in dbserver. [Yn]")
    db.redis.setup if Capistrano::CLI.ui.agree("Do you want to generate redis.conf in app server. [Yn]")
  end
  
  after 'deploy:setup' do
    xapit.setup if Capistrano::CLI.ui.agree("Create xapit configuration file? [Yn]")
  end
  
  after 'deploy:setup' do
    magent.setup if Capistrano::CLI.ui.agree("Create magent configuration file?[Yn]")
  end
  
  
#  after 'deploy:setup' do
#    bluepill.install if Capistrano::CLI.ui.agree("Do you want to install the bluepill monitor? [Yn]")
#    bluepill.setup if Capistrano::CLI.ui.agree("Create bluepill configuration file? [Yn]")
#  end if is_using('bluepill', :monitorer)
  
  
  after 'deploy:setup' do
    nginx.setup if Capistrano::CLI.ui.agree("Create nginx configuration file? [Yn]")
  end if is_using_nginx
  
  after 'deploy:setup' do
    unicorn.setup if Capistrano::CLI.ui.agree("Create unicorn configuration file? [Yn]")
  end if is_using_unicorn
  
  after "deploy:update_code" do
    symlinks.make
    bundler.install
    assets.precompile
  end
  
  
end