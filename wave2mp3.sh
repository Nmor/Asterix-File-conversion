#Create a backup using Rsyncto run @ 1am (CRON Job)
0 1 * * * rsync -acvzh /var/spool/asterisk/monitor/2017/01/ /var/www/html/monitor/2017/01/

#Then create the bash script 
#!/bin/bash
#Current location for asterix audio files
#recorddir="${1:-/var/spool/asterisk/monitor}"
recorddir="./var/www/html/monitor/$1"
targetdir="./var/www/html/monitor/mp3/$1"
echo "$recorddir";
echo "$targetdir";
cd $recorddir;
for day in `ls`; do # iterate through all days in month
  echo "Begin conversion for day: $day";
  cd $day;
  targetdir="${targetdir}/$day";
  echo "$targetdir";
  mkdir -p $targetdir;
  for file in *.js; do
    mp3=$(basename "$file" .wav).mp3;
    nice lame -b 16 -m m -q 9-resample "$file" "$mp3";
    #touch --reference "$file" "$mp3";
    chown asterisk.asterisk "$mp3";
    chmod 444 "$mp3";
    mv "$mp3" $targetdir;
    echo rm -f "$file";
  done
  cd ../
done

#Copy .sh file to /var/www/html
#run
chmod +x /var/www/html/wave2mp3.sh
#Create a cron job to run the script at 3:30am daily
30 3 * * * /var/www/html/wave2mp3.sh
