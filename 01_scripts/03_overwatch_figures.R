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
# Order by sum of usage
#wanted_users = ram_usage %>%
#  group_by(., User) %>%
#  summarise(., total=sum(Unused)) %>%
#  arrange(., desc(total)) %>%
#  top_n(., num_users) %>%
#  select(User)

# Order by max usage
wanted_users = ram_usage %>%
  group_by(., User) %>%
  summarise(., maximum=max(Unused)) %>%
  arrange(., desc(maximum)) %>%
  top_n(., num_users) %>%
  select(User)

# Reorder users by decreasing order of wasted ressources
ram_usage$User = factor(ram_usage$User, levels=pull(wanted_users, User))

# Get only `num_users` users
subset = ram_usage[ram_usage$User %in% wanted_users$User, ]

# Produce figure
pdf(output_file, width=18, height=6)
    ggplot(subset, aes(x=Time, y=Unused, group=Usergroup, color=User)) + #, linetype=User)) + 
      geom_line(linewidth=1.0, alpha=0.6) +
      xlab("Time") +
      ylab("BETTER   <-----------      Unused RAM in Gb      ----------->   WORSE") +

      # Log scale
      #scale_y_continuous(trans='log10', limits=c(max(20, min(subset$Unused)), min(2000, max(subset$Unused))),
      #                   breaks=c(1, 2, 3, 5, 7,
      #                            10, 15, 20, 30, 40, 50, 70,
      #                            100, 150, 200, 300, 400, 500, 700,
      #                            1000, 1500, 2000, 3000),
      #                   minor_breaks=c()) +

      # Linear scale
      scale_y_continuous() +
      theme_bw() +
      theme(legend.key.width = unit(2, "cm"))
dev.off()
