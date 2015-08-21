FROM java:8u40-jre

# Download and unzip Stash Backup Client

ENV STASH_BACKUP_CLIENT_VERSION 1.9.1

RUN curl -Lks https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/stash/backup/stash-backup-distribution/${STASH_BACKUP_CLIENT_VERSION}/stash-backup-distribution-${STASH_BACKUP_CLIENT_VERSION}.zip -o /root/stash-backup-client.zip
RUN mkdir /opt/stash
RUN unzip /root/stash-backup-client.zip -d /opt/stash
RUN mv /opt/stash/stash-backup-client-* /opt/stash/stash-backup-client

## Add in our init script

ADD run.sh /run.sh
RUN chmod +x /run.sh

## Setup dirs
#
WORKDIR /opt/stash
VOLUME /opt/atlassian-home
VOLUME /opt/backup

# Default place for Stash Home location
ENV STASH_HOME /opt/atlassian-home
ENV BACKUP_HOME /opt/backup

ENTRYPOINT ["/run.sh"]
