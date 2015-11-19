### Bitbucket Backup Client Docker image

> Note: With 4.0, Atlassian has changed the official name to Bitbucket Server! You'll still see some references to stash in this readme but I have updated all necessary code and Dockerfile references properly!


See [here](https://confluence.atlassian.com/display/STASH/Using+the+Stash+Backup+Client) for documentation on the backup client.

A simple script has been included that takes environment variables and adds them as defines to the java command.

The flow here looks like this:

1. Generate the name for the new backup and clear out any previous backups in the BACKUP_HOME
2. Spawn the backup client. This backs up the stash data directory and database in a tar archive. It also outputs a log file of the entire run.
3. Tar (to include the log file), compress (xz with lzma2), encrypt (gpg symmetric key), and copy the archive to s3 (awscli s3 cp).
4. Remove the archive after its been uploaded. (We assume its been uploaded and is no longer needed)
5. Wait TIMEOUT to do it all again.

#### Up and Running

See the included `docker-compose.yml.example` file which gives a lose example of how I deploy stash in my environment. 
Here is a stanza from that example focused on just utilizing this image:

```
stashbackupclient:  
    image: inanimate/stash-backup-client:1.0 
    restart: always  
    links:  
        - stash  
        - postgresql  
    volumes_from:  
        - stash  
    environment:  
        - "STASH_USER=stashadmin"  
        - "STASH_PASSWORD=HARDCOREPASSWORDNOWAIHAX0R"  
        - "STASH_BASE_URI=http://stash:7990/"  
        - "AWS_ACCESS_KEY_ID=YOURAWSACCESSKEYBR0"  
        - "AWS_SECRET_ACCESS_KEY=SECRETKEYBREH" 
        - "BUCKET=s3://BUCKETNAME/SUBDIRECTORY"  
        - "SYMMETRIC_PASSPHRASE=SUPERDUPERSECUREPASSWORD"  
```

A few important points here:

* Linking is important here. The stash backup client needs to be able to access the webui and database to fully backup.
* We `volumes-from` the `stash` container as the backup client archives the stash home/data directory (which includes your repositories)
* I'll be tagging my hub repo exactly to the git repository. I encourage you to always pull from a tag as defaults may change over time etc.. 

#### Environment variables 

##### *Required* 


* `BITBUCKET_USER` - The Administrative user account in which to create the backup from.
* `BITBUCKET_PASSWORD` - The password for the above administrative user.
* `BITBUCKET_BASE_URI` - The base uri in which to access your stash instance i.e. `http://git.example.net/`
* `AWS_ACCESS_KEY_ID` - AWS S3 access key. 
* `AWS_SECRET_ACCESS_KEY` - AWS S3 secret key. 
* `BUCKET` - AWS S3 bucket (and folder) to store the backup. i.e. `s3://herpderpbucket/folder` 
* `SYMMETRIC_PASSPHRASE` - The gpg symmetric passphrase to use to encrypt your file. 

##### *Optional* 
* `BACKUP_HOME` - The place for stash-backup-client to dump the backup. (default: `/opt/backup`; *leave this as is for compression, encryption, and sending to s3 to work properly. See `run.sh` for more.*)
* `BITBUCKET_HOME` - The home directory of your stash installation (default: `/var/atlassian/application-data/stash`; *the location this container will inherit from your volumes{-from} in which your install home lives*)
* `TIMEOUT` - How often perform backup, in seconds. (default: `86400`) 
* `NAME_PREFIX` - A prefix in front of the date i.e. `jira-data-dir-backup` (default: `stash-archive`) 
* `GPG_COMPRESSION_LEVEL` - The compression level for gpg to use (0-9). (default: `0`; *not recommended since we're using xz*) 
* `XZ_COMPRESSION_LEVEL` - The compression level for xz (lzma2) to use (0-9). (default: `9`; *this is the best compression level*) 
* `CIPHER_ALGO` - The cipher for gpg to utilize when encrypting your archive. (default: `aes256`) 
* `EXTENSION` - The extension to use for the backup file i.e. `tgz,tar.xz,bz2` (default: `.tar.xz.gpg`) 
* `AWSCLI_OPTIONS` - Provide some arguments to awscli (default: `--sse`; *[enabling server side encryption](http://docs.aws.amazon.com/AmazonS3/latest/dev/serv-side-encryption.html)*) See [here](http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html) for possibilities. 

> All other [aws-cli](https://github.com/aws/aws-cli) variables are also supported. 

#### A few notes

* Use spaces in your buckets, prefix, or extension *at your own risk*!
* I really didn't feel like using cron. Deal with it.
* One day, I'll implement asymmetric encryption so you can use your gpg keys. For now, [this](https://hub.docker.com/r/siomiz/postgresql-s3/) image does...maybe you could make your own ;P


> **Restorability has not yet been completed. It is on the roadmap!**
