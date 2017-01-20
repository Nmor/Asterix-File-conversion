#Create a script to atuo create daily and monthly and daily folders @ 12am
0 0 * * * /usr/local/bin/FoldersCreate.sh
#Folder Creation script
#!/bin/bash
HOME_DIRS="/var/www/html/monitor/ /var/www/html/monitor/mp3 /var/spool/asterisk/monitor"
DATE_DIR=$(date +%Y/%m)
DAY_DIR=$(date +%d)

for FOLDER in $HOME_DIRS; do
    mkdir -p "${FOLDER}/${DATE_DIR}/${DAY_DIR}"
done

#Create a backup using Rsync to run @ 1am (CRON Job)
0 1 * * * rsync -acvzh /var/spool/asterisk/monitor/2017/01/ /var/www/html/monitor/2017/01/

#Then create the bash script to convert the backed up file 
#!/bin/bash
DATE_DIR=$(date +%Y/%m)
DAY_DIR=$(date +%d)
recorddir="${1:-/var/www/html/monitor/${DATE_DIR}/${DAY_DIR}}"
cd $recorddir;
for file in *.wav; do
mp3=$(basename "$file" .wav).mp3;
nice lame -b 16 -m m -q 9-resample "$file" "$mp3";
#touch --reference "$file" "$mp3";
chown asterisk.asterisk "$mp3";
chmod 444 "$mp3";
mv "$mp3" /var/www/html/monitor/mp3/${DATE_DIR}/${DAY_DIR};
rm -f "$file";
done

#Copy .sh file to /usr/bin/local/
#run
chmod +x /usr/bin/local/wave2mp3.sh
#Create a cron job to run the script at 3:30am daily
30 3 * * * /usr/bin/local/wave2mp3.sh
