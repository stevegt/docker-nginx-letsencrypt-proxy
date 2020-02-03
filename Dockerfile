FROM nginx:latest
LABEL maintainer="stevegt@t7a.org"

RUN apt-get update -qq && \
    apt-get install software-properties-common -y
 
RUN add-apt-repository ppa:certbot/certbot

RUN apt-get install cron python-certbot-nginx -y

RUN apt-get install -y iputils-ping net-tools dnsutils procps

COPY example.com.conf /
COPY crontab /
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
