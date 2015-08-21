FROM java:8u40-jre

# Download and unzip Stash Backup Client

ENV STASH_BACKUP_CLIENT_VERSION 1.9.1

RUN curl -Lks https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/stash/backup/stash-backup-distribution/${STASH_BACKUP_CLIENT_VERSION}/stash-backup-distribution-${STASH_BACKUP_CLIENT_VERSION}.zip -o /root/stash-backup-client.zip
RUN mkdir /opt/stash
RUN unzip /root/stash-backup-client.zip -d /opt/stash
RUN mv /opt/stash/stash-backup-client-* /opt/stash/stash-backup-client

## Lets install the necessities to compress, encrypt, and send to s3

RUN apt-get update && \ 
     apt-get install -y -q gnupg xz-utils python-setuptools ca-certificates && \ 
     easy_install pip && \ 
     pip install awscli 

## Add in our init script

ADD run.sh /run.sh
RUN chmod +x /run.sh

## Setup dirs
#
WORKDIR /opt/stash
#VOLUME /opt/atlassian-home

## Setup a volume and var for the default backup output location
VOLUME /opt/backup
ENV BACKUP_HOME /opt/backup

ENTRYPOINT ["/run.sh"]
