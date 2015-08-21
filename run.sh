#!/bin/bash -e


if [ -n "$STASH_USER" ]; then
  OPTS="$OPTS -Dstash.user=$STASH_USER"
else
  echo "You must enter an Administrative user in which to use to backup Stash!"
  exit 1
fi
if [ -n "$STASH_PASSWORD" ]; then
  OPTS="$OPTS -Dstash.password=$STASH_PASSWORD"
else
  echo "You must enter the password of the Administrative user!"
  exit 1
fi
if [ -n "$STASH_BASE_URI" ]; then
  OPTS="$OPTS -Dstash.baseUrl=$STASH_BASE_URI"
else
  echo "Please enter a base uri in which to access the Stash instance!"
  exit 1
fi

## Lets see if they give us a new BACKUP_HOME to use. Or else, this is already set in the dockerfile.

if [ -n "$BACKUP_HOME" ]; then
  OPTS="$OPTS -Dbackup.home=$BACKUP_HOME"
fi

## Omnom/Check ALL the vars

: ${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID not specified"} 
: ${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY not specified"} 
: ${BUCKET:?"BUCKET not specified"} 
: ${SYMMETRIC_PASSPHRASE:?"SYMMETRIC_PASSPHRASE not specified"} 

STASH_HOME=${STASH_HOME:-/var/atlassian/application-data/stash}

TIMEOUT=${TIMEOUT:-86400}
XZ_COMPRESSION_LEVEL=${XZ_COMPRESSION_LEVEL:-9}
CIPHER_ALGO=${CIPHER_ALGO:-aes256}
GPG_COMPRESSION_LEVEL=${GPG_COMPRESSION_LEVEL:-0}
NAME_PREFIX=${NAME_PREFIX:-stash-archive}
EXTENSION=${EXTENSION:-.tar.xz.gpg}
AWSCLI_OPTIONS=${AWSCLI_OPTIONS:---sse}

backup_and_stream_to_s3() { 

while true
  do
    BACKUP="${NAME_PREFIX}_`date +"%Y-%m-%d_%H-%M"`${EXTENSION}" 
    echo "Set backup file name to: $BACKUP" 
    echo "Starting stash backup.." 
    rm -f ${BACKUP_HOME}/*
    java $OPTS -jar /opt/stash/stash-backup-client/stash-backup-client.jar
    xz -${XZ_COMPRESSION_LEVEL} -zf -c ${BACKUP_HOME}/* | gpg -c --cipher-algo ${CIPHER_ALGO} -z ${GPG_COMPRESSION_LEVEL} --passphrase "${SYMMETRIC_PASSPHRASE}" | aws s3 cp - "${BUCKET}/${BACKUP}" "${AWSCLI_OPTIONS}"
    rm -f ${BACKUP_HOME}/*
    echo "Backup finished! Sleeping ${TIMEOUT}s" 
    sleep $TIMEOUT 
  done 

}



wait
