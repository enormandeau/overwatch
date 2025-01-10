#!/bin/bash
# Monitor memory usage on comutation servers using SLURM
# WARNING This code will not work on other servers

# Get RAM usage from users with running SLURM jobs
# Create needed SLURM command
function sq {
    squeue -o "%.8i %.9P %.20j %.4C %.8u %.2t %.11M %.11l %.5D %.20R %.10m" |
        grep -E "^|$USER"
    }

# Global variables
LOOP_DELAY=60
REMOTE="USER@111.222.333.444:~/Desktop"
OUTPUT_FOLDER="02_data"
FIGURE_FOLDER="03_figures"

# Get time
now=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Collect data and update figure in a loop
while true
do
    # Get user and reserved RAM data from SLURM
    sq | grep " R " | grep -v "gpu" | awk '{print $5","$11}' > .overwatch_data.01

    # Get actual usage from top
    cat .overwatch_data.01 |
        cut -d ',' -f 1 |
        sort -u |
        while read user
        do
            top -b -u "$user" -n 1 |
                grep "$user" |
                awk '{print $2","$6}'
        done > .overwatch_data.02

    # Compute total reserved and used RAM
    ./01_scripts/01_get_ram_usage_per_user.py .overwatch_data.01 .overwatch_data.02 \
        >> "$OUTPUT_FOLDER"/overwatch_data_"$now".csv

    # Prepare data
    ./01_scripts/02_format_usage_data_for_figures.py "$OUTPUT_FOLDER"/overwatch_data_"$now".csv "$OUTPUT_FOLDER"/overwatch_figure.data

    # Produce figure
    ./01_scripts/03_overwatch_figures.R "$OUTPUT_FOLDER"/overwatch_figure.data "$FIGURE_FOLDER"/overwatch_figure"$SERVER".pdf

    # Rsync to other computer
    rsync -avhP "$FIGURE_FOLDER"/overwatch_figure"$SERVER".pdf "$REMOTE"

    # Wait before next iteration
    sleep "$LOOP_DELAY"
done
