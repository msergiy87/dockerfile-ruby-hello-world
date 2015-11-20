# dockerfile-ruby-hello-world
```
docker build -t sergiy/unic ~/my_app
docker run -d -p 80:80 --name my_app_ruby sergiy/unic
```

/etc/init/ruby.conf
```
description "Nginx"
author "Me"
start on filesystem and started docker
stop on runlevel [!2345]
respawn
script
  /usr/bin/docker start my_app_ruby
end script
```
