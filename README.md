### Stash Backup Client Docker image

See [here](https://confluence.atlassian.com/display/STASH/Using+the+Stash+Backup+Client) for documentation on the backup client.

A simple script has been included that takes environment variables and adds them as defines to the java command. So running a backup could look like this:

#### Up and Running

docker run --rm \
  --env STASH_USER=admin \
  --env STASH_PASSWORD=admin \
  --env STASH_BASE_URI=<stash url> \
  --volumes-from=<stash-data-container> \
  -v <place to store backup>:/opt/backup \
  kristoffer/atlassian-stash-backup-client


#### Environment variables 

##### *Required* 


* `STASH_USER` - The Administrative user account in which to create the backup from.
* `STASH_PASSWORD` - The password for the above administrative user.
* `STASH_BASE_URI` - The base uri in which to access your stash instance i.e. `http://git.example.net/`
* `AWS_ACCESS_KEY_ID` - AWS S3 access key. 
* `AWS_SECRET_ACCESS_KEY` - AWS S3 secret key. 
* `BUCKET` - AWS S3 bucket (and folder) to store the backup. i.e. `s3://herpderpbucket/folder` 
* `SYMMETRIC_PASSPHRASE` - The gpg symmetric passphrase to use to encrypt your file. 

##### *Optional* 
* `BACKUP_HOME` - The place for stash-backup-client to dump the backup. (default: `/opt/backup`; *leave this as is for compression, encryption, and sending to s3 to work properly. See `run.sh` for more.*)
* `STASH_HOME` - The home directory of your stash installation (default: `/var/atlassian/application-data/stash`; *the location this container will inherit from your volumes{-from} in which your install home lives*)
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
