##Install Nginx


1. install dependency

    ~~~{.shell}
    apt-get install libpcre3 libpcre3-dev
    apt-get install libssl-dev openssl
    apt-get install libgd2-xpm libgd2-xpm-dev php5-gd
    apt-get install geoip-database geoip-bin libgeoip-dev
    wget http://labs.frickle.com/files/ngx_cache_purge-1.6.tar.gz
    ~~~


2. install nginx

    ~~~{.shell}
    ./configure --prefix=/opt/share/nginx-1.2.2 --with-http_ssl_module --with-pcre --with-ipv6 \
    --conf-path=/opt/etc/nginx/conf/nginx.conf --pid-path=/opt/var/run/nginx.pid \
    --lock-path=/opt/var/run/nginx.lock --with-http_stub_status_module --with-http_flv_module \
    --with-http_geoip_module --with-http_dav_module --with-http_xslt_module \
    --with-http_image_filter_module  --add-module=../ngx_cache_purge-1.6 \
    --add-module=/usr/local/rvm/gems/ruby-1.9.3-p194/gems/passenger-3.0.14/ext/nginx
    ~~~

##Deploy

1. Edit deploy file if you need fix it  
    ~~~{.ruby}
    set :deploy_to, "/opt/var/deploy/iask"
    set :user, "expedia"
    set :password, "expedia"
    set :use_sudo, false
    set :group, "expedia"

        role :web, "172.18.6.88"
        role :app, "172.18.6.88"
        role :db,  "172.18.6.88", :primary => true
    ~~~


2. Prepare for deploy      
    cap production deploy:setup  
    cap production deploy:update

3. Prepare the dependency data server    
    cap production db:mongodb:start    
    cap production db:redis:start    
    
4. Start the index engine server     
    cap production xapit:start

5. Start the server      
    cap production unicorn:start    
    cap production nginx:start
    
    
## Quickly Redeploy     
    cap production deploy:update
    cap production unicorn:restart   
    
Or (if you want to deal with the cache issues.)   
    cap production deploy:update
    cap production unicorn:stop
    cap production unicorn:start




