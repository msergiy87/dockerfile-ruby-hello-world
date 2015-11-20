# Pull base image.
FROM ubuntu:14.04
MAINTAINER  <sergiy_007@ukr.net>

RUN apt-get update
RUN apt-get upgrade -y

# Intall software-properties-common for add-apt-repository
RUN apt-get install -qq -y software-properties-common curl

# Install RVM
RUN curl -sSL https://rvm.io/mpapis.asc | sudo gpg --import -
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "source /usr/local/rvm/scripts/rvm"
RUN /bin/bash -l -c "rvm requirements"

# Install Ruby
RUN /bin/bash -l -c "rvm install 2.0.0"
RUN /bin/bash -l -c "rvm use 2.0.0 --default"
RUN /bin/bash -l -c "echo "gem: --no-document" > ~/.gemrc"
RUN /bin/bash -l -c "gem install bundler"

# Install Rails
RUN /bin/bash -l -c "gem install rails"

# Install Javascript Runtime
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install nodejs -y

# Install app, configure Hello World!
RUN useradd -m -s /bin/bash sergiy
RUN /bin/bash -l -c "cd /home/sergiy && rails new hello_world"
RUN /bin/bash -l -c "rails generate controller pages"
COPY conf/pages_controller.rb /home/sergiy/hello_world/app/controllers/pages_controller.rb
COPY conf/home.html.erb /home/sergiy/hello_world/app/views/pages/home.html.erb
COPY conf/routes.rb /home/sergiy/hello_world/config/routes.rb

# Insatall Unicorn
COPY conf/Gemfile /home/sergiy/hello_world/Gemfile
RUN /bin/bash -l -c "cd /home/sergiy/hello_world && source /usr/local/rvm/scripts/rvm && bundle"
COPY conf/unicorn.rb /home/sergiy/hello_world/config/unicorn.rb 
RUN mkdir -p /home/sergiy/hello_world/shared/pids /home/sergiy/hello_world/shared/sockets /home/sergiy/hello_world/shared/log

# Install Supervisor
RUN apt-get update
RUN apt-get install supervisor -y
COPY conf/unicorn.conf /etc/supervisor/conf.d/unicorn.conf
COPY conf/start.sh /home/sergiy/start.sh
RUN chmod u+x /home/sergiy/start.sh
#RUN supervisorctl reread && supervisorctl update

# Install Nginx.
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -y nginx
RUN rm -rf /var/lib/apt/lists/*
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx
COPY conf/default /etc/nginx/sites-available/default

RUN chown sergiy:sergiy /home/sergiy/ -R

# Define mountable directories.
#VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
##WORKDIR /etc/nginx

# Define default command.
##CMD ["nginx"]

# Expose ports.
EXPOSE 80
##EXPOSE 443

#ENTRYPOINT supervisord -c /etc/supervisor/supervisord.conf
CMD supervisord -c /etc/supervisor/supervisord.conf && /usr/sbin/nginx
