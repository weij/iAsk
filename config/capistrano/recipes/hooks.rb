# Common hooks for all scenarios.
Capistrano::Configuration.instance.load do
  after 'deploy:setup' do
    app.setup
    bundler.setup if Capistrano::CLI.ui.agree("Do you need to install the bundler gem? [Yn]")
    
    upload File.expand_path("../../../config/auth_providers.yml", __FILE__),  "#{shared_path}/config/auth_providers.yml"
    upload File.expand_path("../../../config/newrelic.yml", __FILE__), "#{shared_path}/config/newrelic.yml"
  end
    
  after "deploy:update_code" do
    symlinks.make
    bundler.install
  end
end