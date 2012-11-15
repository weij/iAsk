##Install Nginx


1. install dependency

    ~~~{.shell}
    apt-get update
    
    # rvm requirements
    apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev \
    libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev \
    automake libtool bison subversion pkg-config
    
    # the following packages are required by nginx
    apt-get install libpcre3 libpcre3-dev
    apt-get install libssl-dev openssl
    apt-get install libgd2-xpm libgd2-xpm-dev php5-gd
    apt-get install geoip-database geoip-bin libgeoip-dev
    
    # the following packages are required by xapian
    apt-get install uuid-dev
    
    # install gd
    apt-get install php5-gd
    apt-get install libgd2-xpm libgd2-xpm-dev
    
    # install jdk
    apt-get install default-jdk
    
    apt-get dist-upgrade
    ~~~


2. install nginx

    ~~~{.shell}
    wget http://nginx.org/download/nginx-1.2.4.tar.gz
    tar zxvf nginx-1.2.4.tar.gz
    cd nginx-1.2.4
    
    ./configure --with-http_ssl_module --with-pcre --with-ipv6
    
    make & make install
    sudo ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/
    ~~~

##Deploy

1. Edit deploy file if you need fix it  
    ~~~{.ruby}
    set :deploy_to, "/opt/var/deploy/iask"
    set :user, "deploy"
    set :password, "123456"
    set :use_sudo, false
    set :group, "deploy"

        role :web, "172.18.6.86", :no_release => true
        role :app, "172.18.6.86"
        role :db,  "172.18.6.80", :primary => true, :no_release => true
    ~~~


2. Deploy first time   
    ~~~{.ruby}
    cap production deploy:setup  
    cap production deploy:update
    cap production db:mongodb:start
    cap production db:bootstrap
    cap production deploy:start
    ~~~

3. When server is down, start the server    
    cap production deploy:start
    
## Quickly Redeploy     
    cap production deploy
    