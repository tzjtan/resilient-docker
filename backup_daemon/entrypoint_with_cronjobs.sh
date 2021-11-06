# This script injects a cron task into the Docker initialisation.
# This allows the cronjobs to be updated dynamically without having to rebuild the docker image.

# Depending on whether the cron backup or purge line runs first, there may be xxx_KEEPS or xxx_KEEPS+1 files
# in the corresponding backup folder.
#
# The purge function is carried out by
#     ls -ptr /app/backups/$SUBDIRNAME | grep -v / | head -n -$MINUTE_KEEPS | xargs printf -- '/app/backups/$SUBDIRNAME/%s\n' | xargs readlink -f | xargs --no-run-if-empty rm
# The first 2 pipes are to find all the files (which are not directories, which have / appended with the -p flag.
# The 3rd pipe is to find all the oldest files except the latest N files.
# The 4rd and 5th pipe is to convert the basename into absolute paths.
# The 6th pipe deletes the old files.

# To check the cronfile, open up a cli to the container and inspect
# nano /etc/cron.d/my_crontab

# To extract the tar file:
#    sudo tar -xvpzf backup*.tar.gz -C $PWD --numeric-owner


# To disable, set to 0, e.g, MINUTE_KEEPS=0 disables backups at the minute frequency.
REBOOT_KEEPS=4
MINUTE_KEEPS=10
HOURLY_KEEPS=4
FOURHOURLY_KEEPS=6
DAILY_KEEPS=7
WEEKLY_KEEPS=4
MONTHLY_KEEPS=24




cat > /etc/cron.d/my_crontab << EOF
# Auto-compiled from entrypoint_with_cronjobs.sh
#
# Run using
#    crontab my_crontab
# Useful guide:
#    Cron calculator or checker: https://crontab.guru/
#
# 0 9-18 * * * /home/user/office-hourly-check   # Do every hour from 9am to 6pm
# */10 * * * * /home/user/check-disk-space      # Do every 10 minutes
# @hourly /home/user/check-disk-space           # Do every hour
# @reboot /home/user/check-disk-space           # Do every 10 minutes
#
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (0 to 6 are Sunday to Saturday, or use sun,mon,tue,wed,thu,fri,sat; 7 is Sunday, the same as 0)
# |  |  |  |  |
# *  *  *  *  * 

@reboot          echo "Booted up on:" $(date -u)     >> /app/cron_log.log  2>&1  # This will echo a static date of compilation.
#*  *  *  *  *    echo "Compiled on:" $(date -u)      >> /app/cron_log.log  2>&1  # This will echo a static date of compilation.
#*  *  *  *  *    echo "Alive on:" \$(date -u)    >> /app/cron_log.log  2>&1  # Note the escaped $. This will update every minute.
#*  *  *  *  *    touch /app/cron-is-active.log

EOF






if [ $REBOOT_KEEPS -gt 0 ]; then
	SUBDIRNAME='reboot'
	mkdir -p /app/backups/$SUBDIRNAME
	cat >> /etc/cron.d/my_crontab << EOF
@reboot          tar cvpzf - -C /watch . > /app/backups/$SUBDIRNAME/backup.$(date '+%Y%m%d-%H%M%S%z').tar.gz       # Variant C works (static name).
@reboot          /bin/sh /app/helper_delete_old_tars.sh $SUBDIRNAME $REBOOT_KEEPS

EOF
fi


if [ $MINUTE_KEEPS -gt 0 ]; then
	SUBDIRNAME='minute'
	mkdir -p /app/backups/$SUBDIRNAME
	cat >> /etc/cron.d/my_crontab << EOF
*  *  *  *  *    tar cvpzf - -C /watch . > /app/backups/$SUBDIRNAME/backup.\$(date +\%Y\%m\%d-\%H\%M\%S\%z).tar.gz
*  *  *  *  *    /bin/sh /app/helper_delete_old_tars.sh $SUBDIRNAME $MINUTE_KEEPS

EOF
fi


if [ $HOURLY_KEEPS -gt 0 ]; then
	SUBDIRNAME='hourly'
	mkdir -p /app/backups/$SUBDIRNAME
	cat >> /etc/cron.d/my_crontab << EOF
5  *  *  *  *     tar cvpzf - -C /watch . > /app/backups/$SUBDIRNAME/backup.\$(date +\%Y\%m\%d-\%H\%M\%S\%z).tar.gz
6  *  *  *  *     /bin/sh /app/helper_delete_old_tars.sh $SUBDIRNAME $HOURLY_KEEPS

EOF
fi


if [ $FOURHOURLY_KEEPS -gt 0 ]; then
	SUBDIRNAME='fourhourly'
	mkdir -p /app/backups/$SUBDIRNAME
	cat >> /etc/cron.d/my_crontab << EOF
10 */4 * * *     tar cvpzf - -C /watch . > /app/backups/$SUBDIRNAME/backup.\$(date +\%Y\%m\%d-\%H\%M\%S\%z).tar.gz
11 */4 * * *     /bin/sh /app/helper_delete_old_tars.sh $SUBDIRNAME $FOURHOURLY_KEEPS

EOF
fi


if [ $DAILY_KEEPS -gt 0 ]; then
	SUBDIRNAME='daily'
	mkdir -p /app/backups/$SUBDIRNAME
	cat >> /etc/cron.d/my_crontab << EOF
15  0  *  *  *     tar cvpzf - -C /watch . > /app/backups/$SUBDIRNAME/backup.\$(date +\%Y\%m\%d-\%H\%M\%S\%z).tar.gz
16  0  *  *  *     /bin/sh /app/helper_delete_old_tars.sh $SUBDIRNAME $DAILY_KEEPS

EOF
fi


if [ $WEEKLY_KEEPS -gt 0 ]; then
	SUBDIRNAME='weekly'
	mkdir -p /app/backups/$SUBDIRNAME
	cat >> /etc/cron.d/my_crontab << EOF
20  0   *   *   0    tar cvpzf - -C /watch . > /app/backups/$SUBDIRNAME/backup.\$(date +\%Y\%m\%d-\%H\%M\%S\%z).tar.gz
21  0   *   *   0    /bin/sh /app/helper_delete_old_tars.sh $SUBDIRNAME $WEEKLY_KEEPS

EOF
fi



if [ $MONTHLY_KEEPS -gt 0 ]; then
	SUBDIRNAME='monthly'
	mkdir -p /app/backups/$SUBDIRNAME
	cat >> /etc/cron.d/my_crontab << EOF
25  0   1   *   *    tar cvpzf - -C /watch . > /app/backups/$SUBDIRNAME/backup.\$(date +\%Y\%m\%d-\%H\%M\%S\%z).tar.gz
26  0   1   *   *    /bin/sh /app/helper_delete_old_tars.sh $SUBDIRNAME $MONTHLY_KEEPS


EOF
fi



#cp /etc/cron.d/my_crontab /app/cron_for_checking

#chmod 0644 /etc/cron.d/my_crontab # Not necessary
#chmod 0600 /etc/cron.d/my_crontab # Needs to mark as executable, or else bash wouldn't run.
crontab /etc/cron.d/my_crontab
# Options for service cron are: start, status, restart, reload, stop
#service cron stop # Because we want cron in the foreground
#service cron restart # Not necessary for cron in the foreground

exec "$@"
