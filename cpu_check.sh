#!/bin/bash

# Function to display usage information
usage() {
    echo "Use the following command parameter: bash $0 -c critical_threshold -w warning_threshold -e email_address"
    exit 1
}

# Function to send email with the top 10 CPU-consuming processes
send_email() {
    local subject="$1"
    local email="$2"
    local top_processes=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 11)
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

# Get the total CPU usage (in percent)
TOTAL_CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
used_percentage=$(printf "%.0f" "$TOTAL_CPU") # Round to nearest integer

# Compare CPU usage with thresholds
if [ "$used_percentage" -ge "$critical_threshold" ]; then
    echo "CPU usage ($used_percentage%) exceeds critical threshold ($critical_threshold%)"
    # Bonus: Send email with top 10 CPU-consuming processes
    current_time=$(date '+%Y%m%d %H:%M')
    subject="$current_time cpu_check - critical"
    send_email "$subject" "$email_address"
    exit 2
elif [ "$used_percentage" -ge "$warning_threshold" ]; then
    echo "CPU usage ($used_percentage%) exceeds warning threshold ($warning_threshold%)"
    exit 1
else
    echo "CPU usage ($used_percentage%) is below the warning threshold ($warning_threshold%)"
    exit 0
fi

