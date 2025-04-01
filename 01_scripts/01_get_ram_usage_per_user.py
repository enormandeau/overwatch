#!/usr/bin/env python
"""Get total RAM reserved with SLURM by user for running jobs

Usage:
    <program> slurm_file top_file


Example slurm_file:
--
chrisgra,100G
chrisgra,10G
tacopley,16G
jgemr,40G
jgemr,30G
jgemr,40G
jgemr,40G
majea1,20G
majea1,20G
jeham58,50G

Example top_file:
--
alfer41,0.073t
alfer41,4140
alfer41,4344
alfer41,3080
alfer41,6504
alfer41,5396
alfer41,3164
alfer41,6568
alfer41,3876
alfer41,6932
"""

# Modules
from collections import defaultdict
import datetime
import sys

# Parse user options
try:
    slurm_file = sys.argv[1]
    top_file = sys.argv[2]
except:
    print(__doc__)
    sys.exit(1)

# Global variables
kilo    = 1000
million = 1000 * kilo
billion = 1000 * million
tera    = 1000 * billion

prefix = {"K": kilo, "M": million, "G": billion, "T": tera}

ram_reserved = defaultdict(int)
ram_used = defaultdict(int)

now = datetime.datetime.now()
now = now.replace(microsecond=0)
date = f"{now.isoformat()}"

# Extract info about reserved RAM
with open(slurm_file) as infile:
    for line in infile:
        user, ram = line.strip().split(",")[:2]
        try:
            factor = prefix[ram[-1]]
        except:
            continue
        ram = float(ram[:-1]) * factor / billion
        ram_reserved[user] += ram

# Extract info about used RAM
with open(top_file) as infile:
    for line in infile:
        try:
            user, ram = line.strip().split(",")[:2]
        except:
            continue
        last_char = ram[-1]
        factor = prefix[last_char.upper()] if last_char.isalpha() else kilo
        ram = float(ram[:-1]) if last_char.isalpha() else float(ram)
        ram *= factor / billion
        ram_used[user] += ram

# Compute and report RAM usage stats
for user in sorted(ram_reserved):
    reserved = ram_reserved[user]
    used = ram_used[user]
    unused = reserved - used if used < reserved else 0
    percent = 100 * used / reserved

    # Only consider jobs above 5Go
    if reserved >= 5:
        print(f"{date},{user},{reserved:.3f},{used:.3f},{unused:.3f},{percent:.3f}")
