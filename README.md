# overwatch

Monitoring RAM usage for jobs submitted with SLURM

## Usage
Launch overwatch in the background, ideally in a tmux environment.

```bash
./overwatch.sh 2> /dev/null &
```

- Data is collected in the current `02_data` directory in `overwatch_data_<TIME>.csv`
- Figures are sent to `03_figures`
- Figures can also be sent to remote host with rsync

## TODO
- Add script to create plot for last week (or given period)
- Create plots every hour or 15 minutes with cron?
