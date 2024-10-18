#!/bin/bash

# Function to display usage information
usage() {
    echo "Use the following command parameter:bash $0 -c critical_threshold -w warning_threshold -e email_address"
    exit 1
}

# Function to send email with disk partition information
send_email() {
    local subject="$1"
    local disk_info="$2"
    echo "$disk_info" | mail -s "$subject" "$email_address"
}

# Parse command line options
while getopts ":c:w:e:" opt; do
  case $opt in
    c)
      critical_threshold=$OPTARG
      ;;
    w)
      warning_threshold=$OPTARG
      ;;
    e)
      email_address=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Check if all parameters are provided
if [ -z "$critical_threshold" ] || [ -z "$warning_threshold" ] || [ -z "$email_address" ]; then
    echo "Missing parameters!"
    usage
fi

# Ensure critical threshold is greater than the warning threshold
if [ "$critical_threshold" -le "$warning_threshold" ]; then
    echo "Critical threshold must be greater than warning threshold!"
    #usage
fi

# Get disk usage and check against thresholds
DISK_PARTITION=$(df -P | awk -v crit="$critical_threshold" -v warn="$warning_threshold" '$5 >= crit {print $0}')

if [ -n "$DISK_PARTITION" ]; then
    echo "Disk usage exceeds critical threshold ($critical_threshold%)"
    # Bonus: Send email with disk partition information
    current_time=$(date '+%Y%m%d %H:%M')
    subject="$current_time disk_check - critical"
    send_email "$subject" "$DISK_PARTITION"
    exit 2
else
    DISK_PARTITION_WARNING=$(df -P | awk -v warn="$warning_threshold" '$5 >= warn {print $0}')

    if [ -n "$DISK_PARTITION_WARNING" ]; then
        echo "Disk usage exceeds warning threshold ($warning_threshold%)"
        exit 1
    else
        echo "Disk usage is below the warning threshold ($warning_threshold%)"
        exit 0
    fi
fi

