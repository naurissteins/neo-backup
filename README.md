## NEO Backup - Backup MySQL and Domains
NEO Backup is a robust, easy-to-use Bash script designed for Linux servers to automate the backup of MySQL/MariaDB databases and domain directories. It provides a comprehensive solution for system administrators and webmasters to ensure their critical data is regularly and safely backed up. The script is highly configurable, allowing to set up specific backup schedules, choose what to include or exclude, and manage backup retention periods effectively.

Ideal for server environments where regular backups are critical, such as web hosting servers, application servers, and development environments. It's particularly useful for administrators who need a reliable and automated method to back up their MySQL/MariaDB databases and associated domain data regularly.

**Enhanced Cloud Storage Support**:
- `SFTP` Integration: Facilitates secure file transfer to SFTP servers, offering a reliable method for backing up data over an encrypted connection.
- `Mega.nz` Integration: Supports uploading backups directly to Mega.nz, utilizing its generous storage capacity and robust encryption, which ensures that your backups are not only safe from data loss but also protected from unauthorized access.
- `AWS S3` Integration: Provides the capability to upload backups to AWS S3, benefiting from its high durability, availability, and integrated security features. This integration is ideal for users looking for scalable and cost-effective cloud storage solutions.
- `rclone` Integration: Enables extensive compatibility with over 40 cloud storage providers including Google Drive, Dropbox, and Microsoft OneDrive, among others. rclone is a powerful command-line program to manage files on cloud storage.

**Reliable Database Dumping Tool**:
- `MyDumper` Integration: A high-performance, multi-threaded MySQL backup tool originally designed to perform faster and more reliable backups compared to traditional tools like `mysqldump`. It provides several features that make it an excellent choice for large and complex database environments

------------

**Quick Jump to:**
- [Key Features](#key-features "Key Features")
- [Installation Guide](#installation-guide "Installation Guide")
- [General Backup Settings](#general-backup-settings "General Backup Settings")
- [Domain Backup](#domain-backup "Domain Backup")
- [MySQL Backup](#mysqlmariadb-backup "MySQL/MariaDB Backup")
- [SFTP Backup](#sftp-backup "SFTP Backup")
- [AWS S3 Backup](#aws-s3-backup "AWS S3 Backup")
- [Mega.nz Backup](#meganz-backup "Mega.nz Backup")
- [MyDumper](#mydumper "MyDumper")
- [Rclone](#rclone "Rclone")
- [Run backup script with Cron](#run-backup-script-with-cron "Run backup script with Cron")
- [List of configurable options](#list-of-configurable-options "Log File Output")
- [Log File Output](#log-file-output "List of configurable options")
- [To-do List](#to-do-list "To-do List")



## Key Features
- **Flexible Backup Options**: Enable or disable backups for databases and domain files independently with simple configuration settings.
- **Exclusion Options**: Supports the exclusion of specific databases and domains from the backup process using regular expressions, providing flexibility in targeting exactly what needs to be backed up.
- **Automated Cleanup**: Automatically deletes backups older than a specified number of days, helping manage disk space efficiently.
- **Secure Credential Management**: Utilizes a MySQL option file for database credentials, enhancing security by avoiding the need to hardcode sensitive information in the script.
- **Detailed Logging**: Maintains a detailed log of all operations, including any errors encountered, which assists in monitoring and troubleshooting.
- **Enhanced Cloud Storage Support**: Transfer backups directly to `SFTP`, `Mega.nz` and `S3`. Reliable method for backing up data over an encrypted connection.

## Installation Guide

**1. Download the Script**

To begin, download `neo.sh` and `.neorc` by executing the following command in your terminal. This command will navigate to your home directory, download both files from the repository, and set the appropriate permissions:

```bash
cd ~ && curl -v -o neo.sh https://raw.githubusercontent.com/naurissteins/neo-backup/main/neo.sh && chmod +x neo.sh && curl -v -o .neorc https://raw.githubusercontent.com/naurissteins/neo-backup/main/.neorc && chmod 600 .neorc
```

This setup ensures that:
- `neo.sh` is executable, allowing you to run the script directly.
- `.neorc` has restricted permissions (chmod 600), making it readable and writable only by the file owner, thus securing any sensitive configuration settings.


**2. Running the Script**

You can execute `neo.sh` to start the backup process. The example below specifies how to backup domain files to a specified directory and skips MySQL backup:
```bash
./neo.sh --backup-dir "/backup" --days-to-backup 7 --domain-backup true --mysql-backup false
```

For a complete list of configurable options and additional functionality, you can access the help documentation by running `./neo.sh --help` or `./neo.sh -h` or go to [List of configurable options](#list-of-configurable-options "List of configurable options")

## General Backup Settings

**Arguments**:

- `--backup-dir "/root/backup"` : Base Backup Directory: Specifies the root directory where all backup data will be stored on the server. This directory should have enough space to store the backup data and appropriate permissions to allow the script to write data.
- `--backup-cpu-cores "20"` : Specifies the percentage of CPU cores to use for operations like compressing with xz. By default xz is set to use only a single thread. Allocating too many cores to the script might affect the performance of other applications running on the same server. It’s important to balance the core usage to ensure that the system remains responsive for all tasks.
- `--days-to-backup 7` : Days to Keep Local Backups: Number of days to retain local backup directories before they are automatically deleted. Defines how long (in days) backups should be kept before they are automatically deleted. This helps manage disk space by removing old backups.

**Parameters**:

- `BACKUP_DIR="$USER/backup"`
- `DAYS_TO_BACKUP=7`

## Domain Backup

**Arguments**:

- `--domain-backup true` : Backup Domain Files: Set to **true** to enable backing up of domain directories, **false** to disable. When enabled, each domain's contents are archived.
- `--domain-dir "/www"` : Domains Directory: Path to the directory containing domain folders to be backed up. Specifies the directory that contains subdirectories for each domain you want to back up. Typically, this would be set to a server's web root or user directories.
- `--domain-exclude "domain1|domain2"` : Domains to Skip: Regular expression pattern that matches the names of domain directories to be excluded from the backup. Use the pipe `'|'` character to separate multiple domain names. This means that if you want to skip multiple domains, you should list them separated by a pipe, which acts as an **or** in regular expressions. Each domain name that matches any part of the compiled regular expression will be skipped during the backup process.

**Parameters**:

- `BACKUP_DIR="$USER/backup"`
- `DAYS_TO_BACKUP=7`
- `DOMAIN_EXCLUDE="domain1|domain2"`

## MySQL/MariaDB Backup

**Arguments**:

- `--mysql-backup true` : Backup MySQL Databases: Set to **true** to enable MySQL database backups, **false** to disable. If set to true, the script will perform a backup of all MySQL databases (except those specified in **MYSQL_EXCLUDE**). If set to false, no database backups will be conducted.
- `--mysql-exclude "database1|database2"` : Databases to Skip: Regular expression pattern that matches the names of databases to be excluded from the mysqldump. Use the pipe `'|'` character to separate multiple database names. This means that if you want to skip multiple databases, you should list them separated by a pipe, which acts as an **or** in regular expressions. Each database name that matches any part of the compiled regular expression will be skipped during the mysqldump process.

**Parameters**:

- `MYSQL_BACKUP="true"`
- `MYSQL_EXCLUDE="database1|database2"`

**MySQL User and Password**:

For enhanced security, NEO Backup does not support specifying MySQL user credentials via command line arguments. To configure MySQL access, please edit the `.neorc` file. Under the "MySQL Configuration" section, replace the default credentials with your MySQL credentials. This ensures that sensitive information is securely stored and not exposed through command line history.

- `MYSQL_USER="root"` # MySQL user that can dump all databases, e.g. root
- `MYSQL_PASS="password"` # MySQL user password that can dump all databases
- `MYSQL_HOST="localhost"` # MySQL Hostname (in most case: localhost)
- `MYSQL_PORT="3306"` # MySQL Port (mysql and mariadb default port: 3306)


## SFTP Backup

**Arguments**:

- `--sftp-backup` : Set to true to enable SFTP backup, false to disable
- `--sftp-backup-dir` : Specifies the directory where all backup data will be stored on the SFTP server
- `--sftp-host` : SSH configuration settings to simplify the SFTP command
- `--sftp-days-to-backup` : Number of days to retain SFTP server backup directories before they are automatically deleted

**Parameters**:

- `SFTP_BACKUP="true"`
- `SFTP_BACKUP_DIR="/root/backup"`
- `SFTP_HOST="backupserver"`
- `SFTP_DAYS_TO_BACKUP=14`

### Setting Up SFTP with SSH Keys

**Generate SSH Keys on your local server (if not already done):**

You need an SSH key pair to authenticate to the remote server securely. On your local server (from which you are sending the backups), generate an SSH key pair if you haven't already:
```bash
ssh-keygen -t rsa -b 2048
```

Follow the prompts to specify the file in which to save the key and an optional passphrase for additional security.
- **Enter file in which to save the key** : enter here for example `sftp`
- **Enter passphrase (empty for no passphrase)** : skip it, press enter
- **Enter same passphrase again** : skip it, press enter

Output:
```
Your identification has been saved in sftp
Your public key has been saved in sftp.pub
```

**Copy the Public Key to the Remote SFTP Server**:

Next, you need to copy the public key (sftp.pub) to the remote server's authorized keys:
```bash
ssh-copy-id -i ~/.ssh/sftp.pub -p 22 user@remote-server
```

**Configuring the SFTP Connection on your local server:**

You can use SSH configuration settings to simplify the SFTP command. Add a host configuration in your `~/.ssh/config` file on the local server:
```bash
Host backupserver
    HostName remote-server
    User username
    IdentityFile ~/.ssh/sftp
    Port 22
```
Replace `remote-server` with the actual server IP or hostname and `username` with the actual username on the remote server. IdentityFile should point to your private key if not the default, and Port should be changed if your SSH server uses a non-standard port.

Run the script:
```bash
./neo.sh --sftp-backup true --sftp-backup-dir "/root/backup" --sftp-host "backupserver" --sftp-days-to-backup 7 --domain-backup true
```

## AWS S3 Backup

**Arguments**:

- `--s3-backup true` : This setting controls whether backups should be uploaded to S3. Setting this to `true` enables the backup process to S3, and setting it to `false` disables it.
- `--s3-bucket "bucket_name"` : This specifies the bucket name on S3 where the backups will be stored.
- `--s3-days-to-backup 7` : This setting specifies the number of days to retain the backup directories on S3 before they are automatically deleted.

**Parameters**:

- `S3_BACKUP="false"`
- `S3_BUCKET_NAME="bucket_name"`
- `S3_DAYS_TO_BACKUP=14`

### Install and Configure AWS S3

Ubuntu:
```
sudo apt install awscli
```

Arch Linux
```
sudo pacman -S aws-cli
```

After installing the AWS CLI, you need to configure it with your AWS credentials:
```
aws configure
```

**Enter your AWS credentials**
- `AWS Access Key ID`: Enter your access key ID.
- `AWS Secret Access Key`: Enter your secret access key.
- `Default region name`: Enter the AWS region code (e.g., us-east-1).
- `Default output format`: Enter json (or you can leave this blank).

**Test Configuration**

To verify that your installation and configuration are correct, try listing all your S3 buckets:
```
aws s3 ls
```

If you encounter the error `An error occurred (InvalidAccessKeyId) when calling the ListBuckets operation`, and you are utilizing services such as Wasabi or others non-AWS, you may need to adjust the `endpoint-url` in your configuration file. This adjustment often involves removing the `s3 =` section from your AWS CLI config file.

For example, when using Wasabi, ensure your configuration looks like this:
```
[default]
region = eu-central-1
output = json
endpoint_url = https://s3.eu-central-1.wasabisys.com
```

This setup directs all AWS CLI S3 commands to use the specified endpoint, facilitating proper interaction with your service provider.

Run the script:
```bash
./neo.sh --s3-backup true --s3-bucket "bucket_name" --s3-days-to-backup 30 --domain-backup true
```

## Mega.nz Backup

**Arguments**:

- `--mega-backup true` : Setting this to `true` enables the backup process to Mega.nz, and setting it to `false` disables it
- `--mega-backup-dir "/backup"` : This specifies the directory path on Mega.nz where the backups will be stored
- `--mega-days-to-backup 14` : Number of days to retain MEGA backup directories before they are automatically deleted

**Parameters**:

- `MEGA_BACKUP="false"`
- `MEGA_BACKUP_DIR="/backup"`
- `MEGA_DAYS_TO_BACKUP=14`

**Install and setup Mega CLI**:
- Official website: [https://mega.io/cmd](https://mega.io/cmd "https://mega.io/cmd")
- GitHub page: [https://github.com/meganz/MEGAcmd](https://github.com/meganz/MEGAcmd "https://github.com/meganz/MEGAcmd")

Run the script:
```bash
./neo.sh --mysql-backup true --domain-backup true --mega-backup true --mega-backup-dir "/backup" --mega-days-to-backup 14
```

## Rclone

Enables extensive compatibility with over 40 cloud storage providers including Google Drive, Dropbox, and Microsoft OneDrive, among others. rclone is a powerful command-line program to manage files on cloud storage.

**Arguments**:

- `--rclone true` : Set to `true` to enable rclone, `false` to disable
- `--rclone-remote "aws:bucket"` : Example: GoogleDrive:MyBackup or aws3:bucket, etc.
- `--rclone-days-to-backup 14` : Number of days to retain MEGA backup directories before they are automatically deleted

**Parameters**:

- `RCLONE="false"`
- `RCLONE_REMOTE="aws:bucket"`
- `RCLONE_DAYS_TO_BACKUP=14`

**Install and setup rclone**:
- Official website: [https://rclone.org](https://rclone.org "https://rclone.org")
- GitHub page: [https://github.com/rclone/rclone](https://github.com/rclone/rclone "https://github.com/rclone/rclone")

Run the script:
```bash
./neo.sh --mysql-backup true --domain-backup true --rclone true --rclone-remote "aws:bucket" --rclone-days-to-backup 14
```


## MyDumper

**MyDumper** is a high-performance, multi-threaded MySQL backup tool originally designed to perform faster and more reliable backups compared to traditional tools like `mysqldump`. It provides several features that make it an excellent choice for large and complex database environments.

**Arguments**:

- `--mydumper true` : Setting this to `true` enables the database dump with MyDumper, and setting it to `false` disables it
- `--mydumper-threads 4` : Specifies the number of threads that MyDumper uses for the backup process. Using multiple threads can significantly speed up the backup by allowing parallel processing of multiple tables or chunks of data. The optimal number of threads depends on the hardware capabilities of the server and the workload characteristics. It's recommended to set this to match or be slightly less than the number of CPU cores available to balance performance with resource usage
- `--mydumper-verbose 2` : This option allows to increase the verbosity of the output during the dump process, which can be helpful for troubleshooting or monitoring the progress of the dump. Verbosity of output, 0 = silent, 1 = errors, 2 = warnings, 3 = info, default 2

**Parameters**:

- `MY_DUMPER="false"`
- `MY_DUMPER_THREADS=4`
- `MY_DUMPER_VERBOSE=2`

**Recommended Usage**:

**MyDumper** is particularly recommended for backing up large databases where performance and minimal disruption are critical. Its ability to perform parallel dumps dramatically reduces backup time and is especially beneficial for databases with large tables or a high number of tables.
For smaller databases or environments where backup time is less critical, the traditional `mysqldump` tool may suffice. `mysqldump` is simpler to use and requires less configuration but performs backups serially, which can be slower compared to **MyDumper**.

**For Advanced Users**:

NEO Backup script integrates MyDumper with basic but essential configuration options `--threads`, `--compress`, `--verbose` that are sufficient for most use cases. Advanced users may require additional tuning and customization for specific scenarios. If you need to implement more advanced MyDumper settings such as `--long-query-guard`, `--chunk-filesize`, or others, you can manually add these settings in the `neo.sh` script under the **MySQL Backup** section.

MyDumper offical GitHub page: [https://github.com/mydumper/mydumper](https://github.com/mydumper/mydumper "https://github.com/mydumper/mydumper")

Run the script:
```bash
./neo.sh --mysql-backup true --mydumper true --mydumper-threads 4 --mydumper-verbose 2
```

## Run backup script with Cron
Cron works by reading crontab (cron table) files for predefined commands and scripts set by the user or the system's administrator. Each user can have their own crontab, and there is also a system-wide crontab.
Cron is driven by a daemon known as crond (cron daemon). This daemon checks crontab files and the system-wide crontab directory periodically, typically every minute, to execute tasks scheduled for the current time.

A crontab file consists of cron jobs specified in the following format:

```bash
* * * * * /path/to/neo.sh 2>&1
```

Each asterisk can be replaced by a number and represents a different unit of time:

- **Minute** (0 - 59)
- **Hour** (0 - 23)
- **Day of the month** (1 - 31)
- **Month** (1 - 12)
- **Day of the week** (0 - 6) (Sunday=0 or 7)

**Run a script every midnight**:
```bash
0 0 * * * /path/to/neo.sh 2>&1
```

**Run a backup every day at 3 AM**:
```bash
0 3 * * * /path/to/neo.sh 2>&1
```

**Setting Up a Cron Job**

Open the Terminal.
1. Type `crontab -e` and press Enter. This command opens your user's crontab file in the default text editor.
2. Add a new line to the file with the schedule and command you want to run.
3. Save and close the editor. The crontab will automatically be installed and activated.

Example with Special Syntax:
```bash
@daily /path/to/neo.sh 2>&1
```
This line in a crontab will run the `neo.sh` script every day at midnight.

**Special Syntax**
Apart from specifying schedules manually, crontab also supports special strings for common scheduling patterns:

- **@yearly** or **@annually** (Run once a year at midnight of January 1)
- **@monthly** (Run once a month at midnight of the first day of the month)
- **@weekly** (Run once a week at midnight on Sunday morning)
- **@daily** (Run once a day at midnight)
- **@hourly** (Run once an hour at the beginning of the hour)

**Security Considerations**
When setting up cron jobs, especially as root, ensure that scripts executed are secure and cannot be modified by unauthorized users. Also, check the output and error logs to ensure they run as expected, possibly directing output to a log file for regular review:

```bash
@daily /path/to/neo.sh > /path/to/logfile.log 2>&1
```

This entry directs both stdout and stderr to `logfile.log`.

Using cron effectively can help automate many routine tasks, making system maintenance more manageable and reliable.

## List of configurable options
```
    General Options:
        -h, --help                     Display this help and exit.

        --backup-dir            DIR      Specify the directory for storing all backup data                 Default: "/root/backup"
        --backup-cpu-cores      NUM      Percentage of CPU cores to use for compressing with xz            Default: "1 core"
        --days-to-backup        NUM      Set the number of days to retain local backup files               Default: 7

    Domain Backup Options:
        --domain-backup         BOOL     Enable or disable backing up of domain directories                Default: false
        --domain-dir            DIR      Specify the directory containing domain data to backup            Default: "/home"
        --domain-exclude        PATTERN  List domain directories to exclude from backup, separated by '|'  Example: "domain1|domain2"

    MySQL Backup Options:
        --mysql-backup          BOOL      Enable or disable backing up of MySQL databases                  Default: false
        --mysql-exclude         PATTERN   List MySQL databases to exclude from backup, separated by '|'    Example: "database1|database2"

    MyDumper Options:
        --mydumper              BOOL      Enable or disable database dump with MyDumper                    Default: false
        --mydumper-threads      NUM       Set the number of threads to use                                 Default: 4
        --mydumper-verbose      NUM       0 = silent, 1 = errors, 2 = warnings, 3 = info,                  Default: 2

    SFTP Backup Options:
        --sftp-backup           BOOL      Enable or disable SFTP backup. Default: false
        --sftp-backup-dir       DIR       Specify the SFTP directory for storing backup data               Default: "/backup"
        --sftp-host             HOST      SSH configuration settings to simplify the SFTP command          Default: "backupserver"
        --sftp-days-to-backup   NUM       Days to retain backups on SFTP server                            Default: 14

    AWS S3 Backup Options:
        --s3-backup             BOOL      Enable or disable backup to AWS S3                               Default: false
        --s3-bucket             BUCKET    Specify the S3 bucket for storing backups                        Example: "bucket_name"
        --s3-days-to-backup     NUM       Set the number of days to retain backups on S3                   Default: 14

    Rclone Backup Options:
        --rclone                BOOL      Set to 'true' to enable rclone, 'false' to disable               Default: false
        --rclone-remote         HOST:DIR  Example: GoogleDrive:MyBackup or aws3:bucket                     Example: "aws:bucket"
        --rclone-days-to-backup NUM       Set the number of days to keep backups                           Default: 14

    MEGA Backup Options:
        --mega-backup           BOOL      Enable or disable backup to Mega.                                Default: false
        --mega-backup-dir       DIR       Specify the directory on Mega where backups will be stored       Default: "/backup"
        --mega-days-to-backup   NUM       Days to retain backups on Mega                                   Default: 14

    Logs Options:
        --logs-dir              DIR       Specify the directory for storing backup process logs data       Default: "/root/backup/logs"
        --logs-delete           NUM       Days to retain backup process logs                               Default: 14

    Examples:
        ./backup.sh --backup-dir "/path/to/backup" --mysql-backup true --mysql-exclude "database1|database2"
        ./backup.sh --s3-backup true --s3-bucket "s3://mybucket/backup" --s3-days-to-backup 30 --domain-backup true
```

## Log File Output

**Human Readable LOG**
```bash
  _   _ ______ ____    ____             _                 
 | \ | |  ____/ __ \  |  _ \           | |                
 |  \| | |__ | |  | | | |_) | __ _  ___| | ___   _ _ __   
 | . . |  __|| |  | | |  _ < / _. |/ __| |/ / | | | '_ \  
 | |\  | |___| |__| | | |_) | (_| | (__|   <| |_| | |_) | 
 |_| \_|______\____/  |____/ \__,_|\___|_|\__\__,_| .__/  
                                                  | |     
                                                  |_|     
                                                          
+-------------------------------------------------------+ 
| Author: Nauris Steins                                 | 
| https://github.com/naurissteins/neo-backup            | 
+-------------------------------------------------------+ 

- Using 5 of 12 CPU cores for domain and database compression

| General Backup Settings
- Backup Directory Path: /home/ns/backup
- Days To Backup: 11

| Disk Space Information
- Available Space: 238G, Used: 197G, Total: 457G, Mounted on: /

| Domain Settings
- Domain Backup: enabled
- Domain Directory: /www
- Domains for exclude: website.com, mysite.com

| MariaDB Settings
- MariaDB Backup: enabled
- MariaDB Version: 11.3.2
- Dumping Utility: mydumper
- Databases for exclude: database1, database2

| SFTP Settings
- SFTP Backup: enabled
- SFTP Directory: /backup
- SFTP HOST: backupserver
- SFTP Days to Backup: 14

| AWS S3 Settings
- AWS S3 Backup: enabled
- AWS S3 Bucket: backup.bucket.io
- AWS S3 Days to backup: 14

| MEGA Settings
- MEGA Backup: enabled
- MEGA Directory: /neo-backup
- MEGA Days to backup: 14
- MEGA Used space: 14.80 GB
- MEGA Total space: 200 GB

Starting backup process at sestdiena, 2024. gada 27. aprīlis, 15:29:13 EEST

+-----------------------+
| MariaDB Database Dump |
+-----------------------+
- Dumping database: example
+ Successfully dumped!

- Excluded database: database1, database2
+ Database dump process completed.

+------------------+
| Domain Archiving |
+------------------+
- Processing domain: test.com
+ Successfully archived: test.com

- Excluded domain: website.com, mysite.com
+ Domain archiving completed.

Backup process completed at sestdiena, 2024. gada 27. aprīlis, 15:29:14 EEST

+----------------+
| Backup to SFTP |
+----------------+
sftp> cd /backup/2024-04-27-1529/domains
sftp> put /home/ns/backup/2024-04-27-1529/domains/neo_test.com_2024-04-27_0736.tar.xz
sftp> cd /backup/2024-04-27-1529/mysql
sftp> put /home/ns/backup/2024-04-27-1529/mysql/neo_example_2024-04-27_0736.sql.gz

+ Backup successfully uploaded to SFTP

- Checking for backup directories older than 14 days on SFTP...
- No old backups to delete.

+--------------+
| Backup to S3 |
+--------------+
upload: backup/2024-04-27-1529/domains/neo_test.com_2024-04-27_0736.tar.xz to s3://backup.bucket.io/2024-04-27-1529/domains/neo_test.com_2024-04-27_0736.tar.xz
upload: backup/2024-04-27-1529/mysql/neo_example_2024-04-27_0736.sql.gz to s3://backup.bucket.io/2024-04-27-1529/mysql/neo_example_2024-04-27_0736.sql.gz

+ Backup successfully uploaded to S3

- Checking for backup directories older than 14 days on S3...
- No old backups to delete.

+------------------+
| Backup to rclone |
+------------------+
- Uploading /home/ns/backup/2024-04-30-2315 to r2:cdn ... 

+ Backup successfully uploaded!

- Checking for backup directories older than 14 days...
| Deleted: 2024-04-30-2313/mysql/neo_example_2024-04-30_3793.sql.gz
| Deleted: 2024-04-30-2313/mysql/neo_example_2024-04-30_8214.sql.gz

- Removing empty directories...
+ Old backups deletion completed.


+----------------+
| Backup to MEGA |
+----------------+
TRANSFERRING ||#################################################||(151/151 KB: 100.00 %) 
Upload finished: /neo-backup/2024-04-27-1529
TRANSFERRING ||#################################################||(151/151 KB: 100.00 %) 

+ Backup successfully uploaded to Mega.nz

- Checking for backup directories older than 14 days on Mega.nz...
- No old MEGA backups to delete.

+-------------------------+
| Clean up Local Backups |
+-------------------------+
- Checking for local backup directories older than 11 days...
- No old backups to delete.

- Checking for log files older than 7 days in /home/ns/backup/logs...
- No old logs to delete.

All processes completed at sestdiena, 2024. gada 27. aprīlis, 15:29:24 EEST

Log file copied to today's backup directory: /home/ns/backup/2024-04-27-1529
```

## To-do List

- [x] **Backup MySQL Databases**: Implement MySQL database backups
- [x] **Backup Domain Files**: Implement domain file backups
- [x] **Implement Detailed Logging**: Added detailed logging to track each step of the backup process
- [x] **Automate Backup Uploads to MEGA**: Implement automated upload of backup files to MEGA using `MEGA CLI`
- [x] **Automate Backup Uploads to AWS S3**: Implement automated upload of backup files to Amazon S3 using `AWS S3 CLI`
- [x] **Automate Backup Transfers to External Server**: Implement automated transfer of backup files to an external server using `SFTP`
- [x] **Implement MyDumper**: A high-performance, multi-threaded MySQL backup tool originally designed to perform faster
- [ ] **WebDav solution**: Secure automate backup to `WebDav`
- [ ] **Add Email Notifications for Logging**: Implement functionality to send log notifications via email after each backup session