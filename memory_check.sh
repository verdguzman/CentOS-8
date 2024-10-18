#!/bin/bash

# Function to display usage information
usage() {
    echo "Use the following command parameter:bash $0 -c critical_threshold -w warning_threshold -e email_address"
    exit 1
}

# Function to send email with the top 10 memory-consuming processes
send_email() {
    local subject="$1"
    local email="$2"
    local top_processes=$(ps -eo pid,comm,%mem --sort=-%mem | head -n 11)
    echo "$top_processes" | mail -s "$subject" "$email"
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

# Get total and used memory
TOTAL_MEMORY=$(free | grep Mem: | awk '{print $2}')
USED_MEMORY=$(free | grep Mem: | awk '{print $3}')

# Calculate the used memory percentage
USED_PERCENTAGE=$(( 100 * USED_MEMORY / TOTAL_MEMORY ))

# Compare memory usage with thresholds
if [ "$USED_PERCENTAGE" -ge "$critical_threshold" ]; then
    echo "Memory usage ($USED_PERCENTAGE%) exceeds critical threshold ($critical_threshold%)"
    # Bonus: Send email with top 10 memory-consuming processes
    current_time=$(date '+%Y%m%d %H:%M')
    subject="$current_time memory_check-critical"
    send_email "$subject" "$email_address"
    exit 2
elif [ "$USED_PERCENTAGE" -ge "$warning_threshold" ]; then
    echo "Memory usage ($USED_PERCENTAGE%) exceeds warning threshold ($warning_threshold%)"
    exit 1
else
    echo "Memory usage ($USED_PERCENTAGE%) is below the warning threshold ($warning_threshold%)"
    exit 0
fi
