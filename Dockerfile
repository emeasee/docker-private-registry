#https://github.com/dotcloud/docker-registry/blob/master/Dockerfile
#https://index.docker.io/u/modit/docker-registry-nginx/

FROM registry

MAINTAINER edward "www.twitter.com/wizebee"

RUN apt-get update

# 1st line are dependencies that allow use of add-apt-repository
#2nd line added in order to get the latest nginx
## the 3rd line install nginx, supervisor and apache2-utils which provides htpasswd
#RUN apt-get install -y software-properties-common python-software-properties &&\
    #add-apt-repository -y ppa:nginx/stable &&\
    #apt-get update &&\
    #apt-get install -y nginx apache2-utils supervisor
    
RUN wget http://nginx.org/keys/nginx_signing.key &&\
   apt-key add nginx_signing.key && rm nginx_signing.key &&\ 
   echo "deb http://nginx.org/packages/ubuntu/ saucy nginx"  > /etc/apt/sources.list.d/nginx-saucy.list &&\
   echo "deb-src http://nginx.org/packages/ubuntu/ saucy nginx" >> /etc/apt/sources.list.d/nginx-saucy.list &&\
   apt-get update &&\
   apt-get install -y nginx apache2-utils supervisor

#docker expects nginx to be ran in non daemon mode
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

#enable access from your container to a directory on the host machine (i.e. mounting it)
#note all the mounted directory must be exist/created on your physical server
VOLUME /etc/nginx/sites-enabled
VOLUME /var/log/nginx
VOLUME /etc/nginx/docker-registry.htpasswd
 #chose tomount the ssl certificate instaed of adding
VOLUME /etc/ssl/self-signed-certs/docker-registry.crt 
VOLUME /etc/ssl/self-signed-certs/docker-registry.key

#/etc/ssl/docker-registry
#RUN  mkdir /etc/nginx/ssl

#instead of the the sssl certicates, I chose to mount them as shown above
## Usage: ADD [source directory or URL] [destination directory]
#ADD /etc/ssl/self-signed-certs/docker-registry.crt    /etc/nginx/ssl/docker-registry.crt 
#ADD /etc/ssl/self-signed-certs/docker-registry.key    /etc/nginx/ssl/docker-registry.key

#to avoid conflicting server reponse delete the default file
RUN rm /etc/nginx/nginx.conf 
ADD /etc/nginx/nginx.conf   /etc/nginx/nginx.conf

RUN cp /etc/nginx/sites-enabled/default    /etc/nginx/sites-enabled/default.bak
RUN rm  /etc/nginx/sites-enabled/default
ADD ./docker-registry.conf  /etc/nginx/sites-available/
RUN  ln -s /etc/nginx/sites-available/docker-registry.conf  /etc/nginx/sites-enabled/docker-registry.conf 

#Adding Supervisor’s configuration file
#The default file is called supervisord.conf and is located in /etc/supervisor/supervisord.conf
#back up the default supervisord.conf
RUN cp /etc/supervisor/supervisord.conf  /etc/supervisor/supervisord.conf.bak 
ADD ./supervisord.conf  /etc/supervisor/conf.d/supervisord.conf

ADD ./config_s3.yml   /docker-registry/config/config.yml

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]