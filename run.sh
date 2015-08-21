#!/bin/sh

if [ -n "$STASH_USER" ]; then
  OPTS="$OPTS -Dstash.user=$STASH_USER"
fi
if [ -n "$STASH_PASSWORD" ]; then
  OPTS="$OPTS -Dstash.password=$STASH_PASSWORD"
fi
if [ -n "$STASH_BASE_URI" ]; then
  OPTS="$OPTS -Dstash.baseUrl=$STASH_BASE_URI"
fi
if [ -n "$BACKUP_HOME" ]; then
  OPTS="$OPTS -Dbackup.home=$BACKUP_HOME"
fi

java $OPTS -jar /opt/stash/stash-backup-client/stash-backup-client.jar
