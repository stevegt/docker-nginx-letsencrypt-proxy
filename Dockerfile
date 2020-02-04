FROM nginx:latest
LABEL maintainer="stevegt@t7a.org"

RUN apt-get update -qq && \
    apt-get install software-properties-common -y
 
RUN add-apt-repository ppa:certbot/certbot

RUN apt-get install cron python-certbot-nginx -y

RUN apt-get install -y iputils-ping net-tools dnsutils procps
RUN apt-get install -y netcat

RUN rm -rf /etc/nginx/conf.d
RUN mkdir /etc/nginx/http.d 
RUN mkdir /etc/nginx/stream.d 
# symlink so certbot can find http configs
RUN ln -s /etc/nginx/http.d /etc/nginx/conf.d

COPY nginx.conf /etc/nginx/
COPY stream.conf /
COPY http.conf /
COPY crontab /
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
