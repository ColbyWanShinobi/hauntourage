FROM python:3
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y cron mysql-client awscli
RUN touch /var/log/cron.log
RUN mkdir /code
WORKDIR /code
ADD . /code/
COPY crontab /etc/cron.d/cjob
RUN chmod 0644 /etc/cron.d/cjob
ENV PYTHONUNBUFFERED 1
CMD cron -f