#!/bin/bash

########################################################
# DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING! #
########################################################

# Source the .neorc file
source $HOME/.neorc

# Create directories for backups and logs if they do not exist
mkdir -p ${BACKUP_DIR} ${LOGS_DIR} || { echo "Failed to create base directory structures."; exit 1; }

# Generate a log file
LOG_FILE="${LOGS_DIR}/neo_backup_log_$(date +%Y-%m-%d-%H%M).log"

echo "  _   _ ______ ____    ____             _                 " | tee -a "$LOG_FILE"
echo " | \ | |  ____/ __ \  |  _ \           | |                " | tee -a "$LOG_FILE"
echo " |  \| | |__ | |  | | | |_) | __ _  ___| | ___   _ _ __   " | tee -a "$LOG_FILE"
echo " | . . |  __|| |  | | |  _ < / _. |/ __| |/ / | | | '_ \  " | tee -a "$LOG_FILE"
echo " | |\  | |___| |__| | | |_) | (_| | (__|   <| |_| | |_) | " | tee -a "$LOG_FILE"
echo " |_| \_|______\____/  |____/ \__,_|\___|_|\__\__,_| .__/  " | tee -a "$LOG_FILE"
echo "                                                  | |     " | tee -a "$LOG_FILE"
echo "                                                  |_|     " | tee -a "$LOG_FILE"
echo "                                                          " | tee -a "$LOG_FILE"
echo '+-------------------------------------------------------+ ' | tee -a "$LOG_FILE"
echo '| Author: Nauris Steins                                 | ' | tee -a "$LOG_FILE"
echo '| https://github.com/naurissteins/neo-backup            | ' | tee -a "$LOG_FILE"
echo '+-------------------------------------------------------+ ' | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# Usage information
show_help() {
cat << EOF
Usage: ${0##*/} [options]

    General Options:
        -h, --help                     Display this help and exit.

        --backup-dir          DIR      Specify the directory for storing all backup data                 Default: "/root/backup"
        --backup-cpu-cores    NUM      Percentage of CPU cores to use for compressing with xz            Default: "1 core"
        --days-to-backup      NUM      Set the number of days to retain local backup files               Default: 7

    Domain Backup Options:
        --domain-backup       BOOL     Enable or disable backing up of domain directories                Default: false
        --domain-dir          DIR      Specify the directory containing domain data to backup            Default: "/home"
        --domain-exclude      PATTERN  List domain directories to exclude from backup, separated by '|'  Example: "domain1|domain2"

    MySQL Backup Options:
        --mysql-backup        BOOL      Enable or disable backing up of MySQL databases                  Default: false
        --mysql-exclude       PATTERN   List MySQL databases to exclude from backup, separated by '|'    Example: "database1|database2"

    SFTP Backup Options:
        --sftp-backup         BOOL      Enable or disable SFTP backup. Default: false
        --sftp-backup-dir     DIR       Specify the SFTP directory for storing backup data               Default: "/backup"
        --sftp-host           HOST      SSH configuration settings to simplify the SFTP command          Default: "backupserver"
        --sftp-days-to-backup NUM       Days to retain backups on SFTP server                            Default: 14

    AWS S3 Backup Options:
        --s3-backup           BOOL      Enable or disable backup to AWS S3                               Default: false
        --s3-bucket           BUCKET    Specify the S3 bucket for storing backups                        Example: "bucket_name"
        --s3-days-to-backup   NUM       Set the number of days to retain backups on S3                   Default: 14

    MEGA Backup Options:
        --mega-backup         BOOL      Enable or disable backup to Mega.                                Default: false
        --mega-backup-dir     DIR       Specify the directory on Mega where backups will be stored       Default: "/backup"
        --mega-days-to-backup NUM       Days to retain backups on Mega                                   Default: 14

    Logs Options:
        --logs-dir            DIR       Specify the directory for storing backup process logs data       Default: "/root/backup/logs"
        --logs-delete         NUM       Days to retain backup process logs                               Default: 14

    Examples:
        ./backup.sh --backup-dir "/path/to/backup" --mysql-backup true --mysql-exclude "database1|database2"
        ./backup.sh --s3-backup true --s3-bucket "s3://mybucket/backup" --s3-days-to-backup 30 --domain-backup true

EOF
}


# Define the options
OPTS=$(getopt -o h --long help,backup-dir:,backup-cpu-cores:,days-to-backup:,domain-backup:,domain-dir:,domain-exclude:,mysql-backup:,mysql-exclude:,sftp-backup:,sftp-backup-dir:,sftp-host:,sftp-days-to-backup:,s3-backup:,s3-bucket:,s3-days-to-backup:,mega-backup:,mega-backup-dir:,mega-days-to-backup:,logs-dir:,logs-delete: -n 'parse-options' -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        --backup-dir )
            BACKUP_DIR="$2"
            shift 2
            ;;
        --backup-cpu-cores )
            BACKUP_CPU_CORES="$2"
            shift 2
            ;;
        --days-to-backup )
            DAYS_TO_BACKUP="$2"
            shift 2
            ;;
        --domain-backup )
            DOMAIN_BACKUP="$2"
            shift 2
            ;;
        --domain-dir )
            DOMAINS_DIR="$2"
            shift 2
            ;;
        --domain-exclude )
            DOMAIN_EXCLUDE="$2"
            shift 2
            ;;
        --mysql-backup )
            MYSQL_BACKUP="$2"
            shift 2
            ;;
        --mysql-exclude )
            MYSQL_EXCLUDE="$2"
            shift 2
            ;;
        --sftp-backup )
            SFTP_BACKUP="$2"
            shift 2
            ;;
        --sftp-backup-dir )
            SFTP_BACKUP_DIR="$2"
            shift 2
            ;;
        --sftp-host )
            SFTP_HOST="$2"
            shift 2
            ;;
        --sftp-days-to-backup )
            SFTP_DAYS_TO_BACKUP="$2"
            shift 2
            ;;
        --s3-backup )
            S3_BACKUP="$2"
            shift 2
            ;;
        --s3-bucket )
            S3_BUCKET_NAME="$2"
            shift 2
            ;;
        --s3-days-to-backup )
            S3_DAYS_TO_BACKUP="$2"
            shift 2
            ;;
        --mega-backup )
            MEGA_BACKUP="$2"
            shift 2
            ;;
        --mega-backup-dir )
            MEGA_BACKUP_DIR="$2"
            shift 2
            ;;
        --mega-days-to-backup )
            MEGA_DAYS_TO_BACKUP="$2"
            shift 2
            ;;
        --logs-dir )
            LOGS_DIR="$2"
            shift 2
            ;;
        --logs-delete )
            LOGS_DELETE="$2"
            shift 2
            ;;
        -h | --help )
            show_help
            exit 0
            ;;
        -- )
            shift
            break
            ;;
        * )
            echo "Internal error!"
            exit 1
            ;;
    esac
done

# Calculate the number of available CPU cores, rounding up
total_cores=$(nproc)  # Gets the total number of available cores

# Check if BACKUP_CPU_CORES is set and is a number greater than 0
if [[ -n "$BACKUP_CPU_CORES" && "$BACKUP_CPU_CORES" -gt 0 ]]; then
    percent_to_use=$BACKUP_CPU_CORES
else
    percent_to_use=0  # Default to using a single core if percentage is not set or is invalid
fi

# Calculate cores to use based on the percentage, default to 1 core if percentage is 0
if [ "$percent_to_use" -gt 0 ]; then
    cores_to_use=$(echo "($total_cores * $percent_to_use + 99) / 100" | bc)  # Calculate percentage, round up
else
    cores_to_use=1  # Default to one core
fi

# Ensure at least one core is always used
cores_to_use=$(( cores_to_use > 0 ? cores_to_use : 1 ))
export cores_to_use  # Make sure it is available in subshells

echo "- Using $cores_to_use of $total_cores cores for domain backup compression"
echo | tee -a "$LOG_FILE"

# Determine the SQL command tool based on system installation
if [ -x "$(command -v mariadb)" ]; then
    SQL_CMD="mariadb"
    SQL_VER="MariaDB"
    DUMP_CMD="mariadb-dump"
elif [ -x "$(command -v mysql)" ]; then
    SQL_CMD="mysql"
    SQL_VER="MySQL"
    DUMP_CMD="mysqldump"
else
    echo "No suitable SQL command tool found." | tee -a "$LOG_FILE"
    exit 1
fi

# LOG Backup Settings
echo "| General Backup Settings" | tee -a "$LOG_FILE"
echo "- Backup Directory Path: $BACKUP_DIR" | tee -a "$LOG_FILE"
echo "- Days to Backup: $DAYS_TO_BACKUP" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

echo "| Disk Space Information" | tee -a "$LOG_FILE"
df -h "$BACKUP_DIR" | grep -v Filesystem | awk '{print "- Available Space: " $4 ", Used: " $3 ", Total: " $2 ", Mounted on: " $6}' | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# Domain
if [ "${DOMAIN_BACKUP}" = "true" ]; then
    echo "| Domain Settings" | tee -a "$LOG_FILE"
    echo "- Domain Backup: enabled" | tee -a "$LOG_FILE"
    echo "- Domain Directory: $DOMAINS_DIR" | tee -a "$LOG_FILE"

    # Check if DOMAIN_EXCLUDE is set and not empty
    if [ -n "$DOMAIN_EXCLUDE" ]; then
        # Replace all occurrences of '|' with ', '
        formatted_excludes=$(echo "$DOMAIN_EXCLUDE" | sed 's/|/, /g')
        echo "- Domains for exclude: $formatted_excludes" | tee -a "$LOG_FILE"
    fi
    echo | tee -a "$LOG_FILE"
fi

# MySQL
if [ "${MYSQL_BACKUP}" = "true" ]; then
    echo "| $SQL_VER Settings" | tee -a "$LOG_FILE"
    echo "- $SQL_VER Backup: enabled" | tee -a "$LOG_FILE"

    # Print SQL version for debugging
    version_output=$(${SQL_CMD} --version)
    if echo "$version_output" | grep -q "MariaDB"; then
        version_simple=$(echo "$version_output" | grep -oP '\d+\.\d+\.\d+')
    else
        version_simple=$(echo "$version_output" | grep -oP '\d+\.\d+\.\d+')
    fi
    echo "- $SQL_VER Version: $version_simple" | tee -a "$LOG_FILE"

    # Check if MYSQL_EXCLUDE is set and not empty
    if [ -n "$MYSQL_EXCLUDE" ]; then
        # Replace all occurrences of '|' with ', '
        formatted_excludes=$(echo "$MYSQL_EXCLUDE" | sed 's/|/, /g')
        echo "- Databases for exclude: $formatted_excludes" | tee -a "$LOG_FILE"
    fi
    echo | tee -a "$LOG_FILE"
fi

# SFTP
if [ "${SFTP_BACKUP}" = "true" ]; then
    echo "| SFTP Settings" | tee -a "$LOG_FILE"
    echo "- SFTP Backup: enabled" | tee -a "$LOG_FILE"
    echo "- SFTP Directory: $SFTP_BACKUP_DIR" | tee -a "$LOG_FILE"
    echo "- SFTP HOST: $SFTP_HOST" | tee -a "$LOG_FILE"
    echo "- SFTP Days to Backup: $SFTP_DAYS_TO_BACKUP" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
fi

# AWS S3
if [ "${S3_BACKUP}" = "true" ]; then
    echo "| AWS S3 Settings" | tee -a "$LOG_FILE"
    echo "- AWS S3 Backup: enabled" | tee -a "$LOG_FILE"
    echo "- AWS S3 Bucket: $S3_BUCKET_NAME" | tee -a "$LOG_FILE"
    echo "- AWS S3 Days to backup: $S3_DAYS_TO_BACKUP" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
fi

# MEGA
if [ "${MEGA_BACKUP}" = "true" ]; then
    echo "| MEGA Settings" | tee -a "$LOG_FILE"
    echo "- MEGA Backup: enabled" | tee -a "$LOG_FILE"
    echo "- MEGA Directory: $MEGA_BACKUP_DIR" | tee -a "$LOG_FILE"
    echo "- MEGA Days to backup: $MEGA_DAYS_TO_BACKUP" | tee -a "$LOG_FILE"

    # Get the disk usage statistics from MEGA
    disk_usage=$(mega-df)

    # Extract the used storage line
    used_storage_line=$(echo "$disk_usage" | grep 'USED STORAGE')

    # Extract total bytes and percentage used
    total_bytes=$(echo "$used_storage_line" | grep -oP 'of\s+\K\d+')
    percentage_used=$(echo "$used_storage_line" | grep -oP '\s+\K\d+\.\d+(?=%)')

    # Convert bytes to gigabytes for readability
    total_gb=$(echo "scale=2; $total_bytes / 1024 / 1024 / 1024" | bc)
    used_gb=$(echo "scale=2; $total_gb * $percentage_used / 100" | bc)

    # Display the used and total space in GB
    echo "- MEGA Used space: $used_gb GB" | tee -a "$LOG_FILE"
    echo "- MEGA Total space: $total_gb GB" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
fi

# Generate a unique four-digit random number
RANDOM_SUFFIX=$(printf "%04d" $(( RANDOM % 10000 )))

# Start the backup process
echo "Starting backup process at $(date)" | tee -a "$LOG_FILE"

# Create a new directory for today's backup
CURRENT_DATE=$(date +%Y-%m-%d-%H%M)
TODAYS_BACKUP_DIR="${BACKUP_DIR}/${CURRENT_DATE}"
mkdir -p ${TODAYS_BACKUP_DIR} || { echo "Failed to create today's backup directory" | tee -a "$LOG_FILE"; exit 1; }

# Function for printing styled logs
print_styled_log() {
    local message="$1"
    local len=${#message}
    local border=$(printf -- '-%.0s' $(seq $len))
    echo | tee -a "$LOG_FILE"
    echo "+-$border-+" | tee -a "$LOG_FILE"
    echo "| $message |" | tee -a "$LOG_FILE"
    echo "+-$border-+" | tee -a "$LOG_FILE"
}

# Backup MySQL
if [ "${MYSQL_BACKUP}" = "true" ]; then
    # Start of MySQL backup process
    print_styled_log "$SQL_VER Database Dump"
    MYSQL_BACKUP_DIR="${TODAYS_BACKUP_DIR}/mysql"
    mkdir -p ${MYSQL_BACKUP_DIR} || { echo "Failed to create MySQL backup directory" | tee -a "$LOG_FILE"; exit 1; }

    # Variable to collect skipped databases
    exclude_db=""

    # Start MySQL backup process using user credentials from .backuprc
    databases=$(${SQL_CMD} -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u "${MYSQL_USER}" -p"${MYSQL_PASS}" -e 'show databases;' | grep -Ev "^(Database|mysql|information_schema|performance_schema|phpmyadmin|sys)$")

    for db in $databases; do
        if [[ -z "$MYSQL_EXCLUDE" || ! $db =~ $MYSQL_EXCLUDE ]]; then
            echo "- Dumping database: ${db}" | tee -a "$LOG_FILE"
            if ${DUMP_CMD} -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u "${MYSQL_USER}" -p"${MYSQL_PASS}" --single-transaction "${db}" | gzip > "${MYSQL_BACKUP_DIR}/neo_${db}_$(date +%F)_${RANDOM_SUFFIX}.sql.gz"; then
                echo "+ Successfully dumped: ${db}" | tee -a "$LOG_FILE"
            else
                echo "! Failed to back up database: ${db}" | tee -a "$LOG_FILE"
            fi
        else
            exclude_db+="${db}, "
        fi
    done

    # Remove trailing comma and space
    exclude_db=${exclude_db%, }

    # Display skipped databases if any
    if [ -n "$exclude_db" ]; then
        echo | tee -a "$LOG_FILE"
        echo "- Excluded database: $exclude_db" | tee -a "$LOG_FILE"
    fi

    echo "+ Database dump process completed." | tee -a "$LOG_FILE"
fi

# Backup Domains
if [ "${DOMAIN_BACKUP}" = "true" ]; then
    # Start of Domains backup process
    print_styled_log "Domain Archiving"
    DOMAINS_BACKUP_DIR="${TODAYS_BACKUP_DIR}/domains"
    mkdir -p "${DOMAINS_BACKUP_DIR}" || { echo "Failed to create domains backup directory" | tee -a "$LOG_FILE"; exit 1; }

    # Temporary file to track skipped domains
    temp_skipped_domains_file=$(mktemp)
    trap 'rm -f "$temp_skipped_domains_file"' EXIT

    # Find domains and execute backup
    process_domain() {
        folder="$1"
        domain=$(basename "$folder")
        skip_pattern="$2"
        log_file="$3"
        backup_dir="$4"
        random_suffix="$5"
        temp_skipped="$6"
        date_format=$(date +%F)
        if [[ -n "$skip_pattern" && $domain =~ $skip_pattern ]]; then
            echo "$domain" >> "$temp_skipped"
        else
            echo "- Processing domain: $domain" | tee -a "$log_file"
            tar_output="${backup_dir}/neo_${domain}_${date_format}_${random_suffix}.tar.xz"
            compress_cmd="xz -T $cores_to_use"

            if tar -cf "$tar_output" --use-compress-program="$compress_cmd" -C "$(dirname "$folder")" "$domain"; then
                echo "+ Successfully archived: $domain" | tee -a "$log_file"
            else
                echo "! Failed to back up domain: $domain" | tee -a "$log_file"
            fi
        fi
    }

    export -f process_domain
    find "${DOMAINS_DIR}" -mindepth 1 -maxdepth 1 -type d -exec bash -c 'process_domain "$0" "$@"' {} "$DOMAIN_EXCLUDE" "$LOG_FILE" "$DOMAINS_BACKUP_DIR" "$RANDOM_SUFFIX" "$temp_skipped_domains_file" \;

    # Display skipped domains if any
    if [ -s "$temp_skipped_domains_file" ]; then
        # Read domains from file, adding commas between them
        skipped_domains=$(awk '{printf "%s, ", $0}' "$temp_skipped_domains_file")

        # Remove the final comma and space
        skipped_domains=${skipped_domains%, }

        echo | tee -a "$LOG_FILE"
        echo "- Excluded domain: $skipped_domains" | tee -a "$LOG_FILE"
    fi

    # Explicit cleanup is not needed due to trap
    echo "+ Domain archiving completed." | tee -a "$LOG_FILE"
fi

# Backup process completion
echo | tee -a "$LOG_FILE"
echo "Backup process completed at $(date)" | tee -a "$LOG_FILE"

# SFTP Backup
if [ "${SFTP_BACKUP}" = "true" ]; then
    # Start backup transfer to SFTP
    print_styled_log "Backup to SFTP"

    # Define the remote base directory path for today's backup
    REMOTE_DIR="${SFTP_BACKUP_DIR}/${CURRENT_DATE}"

    # Create base remote directory
    ssh ${SFTP_HOST} "mkdir -p ${REMOTE_DIR}"
    if [ $? -ne 0 ]; then
        echo "! Failed to create base remote directory on SFTP" | tee -a "$LOG_FILE"
        exit 1
    fi

    # Create and upload domains if enabled
    if [ "${DOMAIN_BACKUP}" = "true" ]; then
        REMOTE_DOMAIN_DIR="${REMOTE_DIR}/domains"
        ssh ${SFTP_HOST} "mkdir -p ${REMOTE_DOMAIN_DIR}"
        echo "cd ${REMOTE_DOMAIN_DIR}" > /tmp/sftp_domains_commands.txt
        find "${TODAYS_BACKUP_DIR}/domains" -type f -exec echo put {} \; >> /tmp/sftp_domains_commands.txt
        sftp -b /tmp/sftp_domains_commands.txt ${SFTP_HOST}
        if [ $? -ne 0 ]; then
            echo "! Failed to upload domain backups to SFTP" | tee -a "$LOG_FILE"
            exit 1
        fi
    fi

    # Create and upload MySQL backups if enabled
    if [ "${MYSQL_BACKUP}" = "true" ]; then
        REMOTE_MYSQL_DIR="${REMOTE_DIR}/mysql"
        ssh ${SFTP_HOST} "mkdir -p ${REMOTE_MYSQL_DIR}"
        echo "cd ${REMOTE_MYSQL_DIR}" > /tmp/sftp_mysql_commands.txt
        find "${TODAYS_BACKUP_DIR}/mysql" -type f -exec echo put {} \; >> /tmp/sftp_mysql_commands.txt
        sftp -b /tmp/sftp_mysql_commands.txt ${SFTP_HOST}
        if [ $? -ne 0 ]; then
            echo "! Failed to upload MySQL backups to SFTP" | tee -a "$LOG_FILE"
            exit 1
        fi
    fi

    echo | tee -a "$LOG_FILE"
    echo "+ Backup successfully uploaded to SFTP" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"

    # Deleting old backups from SFTP
    echo "- Checking for backup directories older than ${SFTP_DAYS_TO_BACKUP} days on SFTP..." | tee -a "$LOG_FILE"
    OLD_DIRS=$(ssh ${SFTP_HOST} "find ${SFTP_BACKUP_DIR} -maxdepth 1 -type d -mtime +${SFTP_DAYS_TO_BACKUP}")
    if [ -z "${OLD_DIRS}" ]; then
        echo "- No old backups to delete." | tee -a "$LOG_FILE"
    else
        echo "- Deleting old backup directories..." | tee -a "$LOG_FILE"
        for DIR in ${OLD_DIRS}; do
            ssh ${SFTP_HOST} "rm -rf ${DIR}" && echo "- Deleted ${DIR}" | tee -a "$LOG_FILE"
        done
        echo "+ Old backups deletion completed." | tee -a "$LOG_FILE"
    fi
fi

# AWS S3 Backup
if [ "${S3_BACKUP}" = "true" ]; then
    # Start backup transfer to S3
    print_styled_log "Backup to S3"
    FULL_S3_PATH="s3://${S3_BUCKET_NAME}/${CURRENT_DATE}/"

    # Upload the backup directory to S3
    if aws s3 cp "${TODAYS_BACKUP_DIR}/" "${FULL_S3_PATH}" --recursive; then
        echo | tee -a "$LOG_FILE"
        echo "+ Backup successfully uploaded to S3" | tee -a "$LOG_FILE"
    else
        echo | tee -a "$LOG_FILE"
        echo "! Failed to upload backup to S3" | tee -a "$LOG_FILE"
        exit 1
    fi

    # Deleting old backups from S3
    echo | tee -a "$LOG_FILE"
    echo "- Checking for backup directories older than ${S3_DAYS_TO_BACKUP} days on S3..." | tee -a "$LOG_FILE"

    # Get current date in seconds
    current_date_secs=$(date +%s)

    # Temporary file to track deleted backups
    temp_file=$(mktemp)

    # List and delete old backup directories from S3 based on LastModified
    aws s3 ls "s3://${S3_BUCKET_NAME}/" --recursive | while read -r line; do
        last_modified=$(echo "$line" | awk '{print $1" "$2}')
        last_modified_secs=$(date -d "$last_modified" +%s)
        diff_days=$(( (current_date_secs - last_modified_secs) / 86400 ))

        file_path=$(echo "$line" | awk '{print $4}')

        if [[ $file_path == neo_* ]] && [ $diff_days -gt $S3_DAYS_TO_BACKUP ]; then
            echo "Deleting old backup: $file_path" | tee -a "$LOG_FILE"
            aws s3 rm "s3://${S3_BUCKET_NAME}/$file_path"
            echo "deleted" > "$temp_file"
        fi
    done

    # Check if any backup was deleted
    if [ ! -s "$temp_file" ]; then
        echo "- No old backups to delete." | tee -a "$LOG_FILE"
    else
        echo "+ Backup deletion process completed." | tee -a "$LOG_FILE"
    fi

    # Clean up temporary file, ensuring it exists and is not empty
    if [ -f "$temp_file" ]; then
        rm "$temp_file"
    fi
fi

# Mega.nz backup
if [ "${MEGA_BACKUP}" = "true" ]; then
    # Start backup transfer to MEGA
    print_styled_log "Backup to MEGA"
    # Check if the remote directory exists and create it if it doesn't
    if ! mega-ls "${MEGA_BACKUP_DIR}" >/dev/null 2>&1; then
        echo "- Creating directory: ${MEGA_BACKUP_DIR}" | tee -a "$LOG_FILE"
        mega-mkdir "${MEGA_BACKUP_DIR}"
        if [ $? -ne 0 ]; then
            echo "! Failed to create directory on Mega.nz: ${MEGA_BACKUP_DIR}" | tee -a "$LOG_FILE"
            exit 1
        fi
    fi

    # Upload the backup directory to Mega.nz
    if mega-put "${TODAYS_BACKUP_DIR}" "${MEGA_BACKUP_DIR}/"; then
        echo | tee -a "$LOG_FILE"
        echo "+ Backup successfully uploaded to Mega.nz" | tee -a "$LOG_FILE"
    else
        echo | tee -a "$LOG_FILE"
        echo "! Failed to upload backup to Mega.nz" | tee -a "$LOG_FILE"
        exit 1
    fi

    # Deleting old backups from Mega.nz
    echo | tee -a "$LOG_FILE"
    echo "- Checking for backup directories older than ${MEGA_DAYS_TO_BACKUP} days on Mega.nz..." | tee -a "$LOG_FILE"
    old_found=false
    while IFS= read -r dir; do
        # Check if the directory name contains a date
        if [[ "$dir" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]; then
            dir_date="${dir:0:10}"  # Extract the date part from the directory name
            dir_date_sec=$(date -d "$dir_date" +%s) # Convert date to seconds
            now_sec=$(date +%s) # Current time in seconds
            age_days=$(( (now_sec - dir_date_sec) / 86400 )) # Calculate age in days
            if [ "$age_days" -gt "${MEGA_DAYS_TO_BACKUP}" ]; then
                if [ "$old_found" = false ]; then
                    old_found=true
                fi
                echo "- Deleted: $dir" | tee -a "$LOG_FILE"
                mega-rm -rf "${MEGA_BACKUP_DIR}/${dir}"
            fi
        fi
    done < <(mega-ls "${MEGA_BACKUP_DIR}")
    if [ "$old_found" = false ]; then
        echo "- No old MEGA backups to delete." | tee -a "$LOG_FILE"
    else
        echo "+ Old MEGA backups deletion completed." | tee -a "$LOG_FILE"
    fi
fi

# Start old backup deletion
print_styled_log "Clean up Local Backups"

# Delete old backups
if [ -n "${BACKUP_DIR}" ]; then
    echo "- Checking for local backup directories older than ${DAYS_TO_BACKUP} days..." | tee -a "$LOG_FILE"
    # Store the directories that match the conditions into a variable
    OLD_DIRS=$(find ${BACKUP_DIR} -maxdepth 1 -type d -name "*-*-*-*" -mtime +${DAYS_TO_BACKUP})

    if [ -z "$OLD_DIRS" ]; then
        echo "- No old backups to delete." | tee -a "$LOG_FILE"
    else
        echo "- Starting deletion of backups older than ${DAYS_TO_BACKUP} days..." | tee -a "$LOG_FILE"
        # Read through each directory and delete it
        echo "$OLD_DIRS" | while read dir; do
            echo "- Deleted: $dir" | tee -a "$LOG_FILE"
            rm -rf "$dir"
        done
        echo "+ Old backups deletion completed." | tee -a "$LOG_FILE"
    fi
fi

# Delete old log files
if [ -n "${LOGS_DELETE}" ]; then
    echo | tee -a "$LOG_FILE"
    echo "- Checking for log files older than ${LOGS_DELETE} days in ${LOGS_DIR}..." | tee -a "$LOG_FILE"
    # Find old log files older than the specified number of days in the logs directory
    OLD_LOGS=$(find ${LOGS_DIR} -maxdepth 1 -type f -name "*.log" -mtime +${LOGS_DELETE})

    if [ -z "$OLD_LOGS" ]; then
        echo "- No old logs to delete." | tee -a "$LOG_FILE"
    else
        echo "- Deleting log files older than ${LOGS_DELETE} days..." | tee -a "$LOG_FILE"
        # Read through each log file and delete it
        echo "$OLD_LOGS" | while read log_file; do
            echo "- Deleted: $log_file" | tee -a "$LOG_FILE"
            rm -f "$log_file"
        done
        echo "+ Log file cleanup completed." | tee -a "$LOG_FILE"
    fi
fi

echo | tee -a "$LOG_FILE"
echo "All processes completed at $(date)" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# After all operations complete, copy the LOG_FILE to the backup directory
if [ -d "${TODAYS_BACKUP_DIR}" ]; then
    cp "$LOG_FILE" "${TODAYS_BACKUP_DIR}/"
    echo "Log file copied to today's backup directory: ${TODAYS_BACKUP_DIR}" | tee -a "$LOG_FILE"
else
    echo "Today's backup directory does not exist, unable to copy log file." | tee -a "$LOG_FILE"
fi
