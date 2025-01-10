#!/usr/bin/env python3
"""Prepare usage data for script by annotating regions of RAM usage

Usage:
    <program> input_file output_file
"""

# Modules
from datetime import datetime
import sys

# Parse user input
try:
    input_file = sys.argv[1]
    output_file = sys.argv[2]
except:
    print(__doc__)
    sys.exit(1)

# Iterate over data to annotate regions of RAM usage
user_info = dict()
print("Preparing usage data for figure...")

with open(input_file) as infile:
    with open(output_file, "w") as outfile:
        for line in infile:
            time, user, reserved, used, unused, percent = line.strip().split(",")
            time = time.split(".")[0]

            # If new user, create region 1 at time 0
            if user not in user_info:
                user_info[user] = [time, 1]

            else:
                # Compute time since last data point
                last_time = datetime.strptime(user_info[user][0], "%Y-%m-%dT%H:%M:%S")
                current_time = datetime.strptime(time, "%Y-%m-%dT%H:%M:%S")
                time_diff = (current_time - last_time).total_seconds() / 60.0
                user_info[user][0] = time

                # If last time is more than 10 minutes away, increment region
                if time_diff > 10:
                    user_info[user][1] += 1

                # Write new info to output file
                outfile.write(",".join(
                    [time, user, user + "_group" + str(user_info[user][1]),
                        reserved, used, unused, percent]
                    ) + "\n")
