#!/usr/bin/env Rscript

# Cleanup
rm(list=ls())

# Packages
require(ggplot2)
require(dplyr)

# Getting user arguments
args = commandArgs(trailingOnly=TRUE)
input_file = args[1]
output_file = args[2]

# Global variables
num_users = 8

# Read data
ram_usage = read.csv(input_file, header=F, stringsAsFactors=F)
names(ram_usage) = c("Time", "User", "Usergroup", "Reserved", "Used", "Unused", "PercentUsed")
ram_usage$Time = as.POSIXct(ram_usage$Time, format="%Y-%m-%dT%H:%M:%S")

# Select wanted users
wanted_users = ram_usage %>%
  group_by(., User) %>%
  summarise(., total=sum(Unused)) %>%
  arrange(., desc(total)) %>%
  top_n(., num_users) %>%
  select(User)

# Reorder users by decreasing order of wasted ressources
ram_usage$User = factor(ram_usage$User, levels=pull(wanted_users, User))

# Get only `num_users` users
subset = ram_usage[ram_usage$User %in% wanted_users$User, ]

# Produce figure
pdf(output_file, width=12, height=6)
    ggplot(subset, aes(x=Time, y=Unused, group=Usergroup, color=User, linetype=User)) + 
      geom_line(linewidth=1, alpha=0.8) +
      theme(legend.key.width = unit(6, "line")) +
      xlab("Time") +
      ylab("BETTER   <-----------      Unused RAM in Gb      ----------->   WORSE") +
      scale_y_continuous(trans='log10', limits=c(10, 1500),
                         breaks=c(1, 2, 3, 4, 5, 7,
                                  10, 20, 30, 40, 50, 70,
                                  100, 200, 300, 400, 500, 700, 1000, 2000),
                         minor_breaks=c()) +
      theme_bw()
dev.off()
