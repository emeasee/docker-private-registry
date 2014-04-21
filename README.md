# Adds Niginx, supervisor and apache2_utils to docker private registry.

# Since we are mounting certain volumes, you must make sure those directories exists
     VOLUME /etc/nginx/sites-enabled
     VOLUME /var/log/nginx
    VOLUME /etc/nginx/docker-registry.htpasswd
#create and mounts ssl certificates. 
#See tutorial here: https://www.digitalocean.com/community/articles/how-to-create-a-ssl-certificate-on-nginx-for-ubuntu-12-04
   VOLUME /etc/ssl/self-signed-certs/docker-registry.crt 
   VOLUME /etc/ssl/self-signed-certs/docker-registry.key

# Run it
-- To build, make sure you have Docker installed, clone this repo somewhere, and then run:
-- if you build it to run in development then in the dockerfile, comment out 'ADD ./config_s3.yml   /docker-registry/config/config.yml'
     docker build -t <yourname>/docker-private-registry .

-- Or, alternately, build directly from the github repo:

    docker build -t <yourname>/docker-private-repository  git@github.com:mankind/docker-private-registry.git

-- Then run it in 

     docker run -d -p 5000:80  <yourname>/docker-private-repository
     
-- Run it in productionby supplying the correct aws details if you use that or storage.
     docker run -p 5000:80 -e SETTINGS_FLAVOR=prod -e AWS_KEY=X -e AWS_SECRET=Y -e AWS_BUCKET=images <yourname>/docker-private-repository

