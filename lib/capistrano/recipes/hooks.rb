# Common hooks for all scenarios.
Capistrano::Configuration.instance.load do
  
  after 'deploy:setup' do
    app.setup    
    bundler.setup if Capistrano::CLI.ui.agree("Do you need to install the bundler gem? [Yn]")
  end
  
  after "deploy:setup" do
    db.setup if Capistrano::CLI.ui.agree("Create mongoid.yml in app's shared path? [Yn]")
  end
  
  after 'deploy:setup' do
    xapit.setup if Capistrano::CLI.ui.agree("Create xapit configuration file? [Yn]")
  end

  
  after 'deploy:setup' do
    magent.setup if Capistrano::CLI.ui.agree("Create magent configuration file?[Yn]")
  end if is_using('bluepill', :monitorer)
  
  
  after 'deploy:setup' do
    bluepill.install if Capistrano::CLI.ui.agree("Do you want to install the bluepill monitor? [Yn]")
    bluepill.setup if Capistrano::CLI.ui.agree("Create bluepill configuration file? [Yn]")
  end if is_using('bluepill', :monitorer)
  
  
  after 'deploy:setup' do
    nginx.setup if Capistrano::CLI.ui.agree("Create nginx configuration file? [Yn]")
  end if is_using_nginx
  
  after 'deploy:setup' do
    unicorn.setup if Capistrano::CLI.ui.agree("Create unicorn configuration file? [Yn]")
  end if is_using_unicorn
  
  after "deploy:update_code" do
    symlinks.make
    bundler.install
  end
  
  after 'deploy:update', 'assets:symlink'
  after 'deploy:update', 'assets:precompile'
  
end