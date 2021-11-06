#!/bin/sh

# Run using the following to keep only 10 files in the "minute" folder
# sh helper_delete_old_tars.sh minute 10

# This is a helper script that deletes old tar files in a directory

# The following command somehow works in the terminal, but does not work in a cron.
# /bin/sh -c "ls -ptr /app/backups/$SUBDIRNAME | grep -v / | head -n -$MINUTE_KEEPS | xargs -x --no-run-if-empty -d '\n' printf -- '\"/app/backups/$SUBDIRNAME/%s\"\n'" >> /app/log.txt 2> /app/error.log 2>&1
# This helper script is thus to go around this problem, so that the cron script can execute this helper script instead.

echo "Requested cleaning up dir $1 to retain only $2 files"

SUBDIRNAME=$1
COUNT_KEEPS=$2

ls -ptr /app/backups/$SUBDIRNAME | grep -v / | head -n -$COUNT_KEEPS | xargs -x --no-run-if-empty -d '\n' printf -- "\"/app/backups/$SUBDIRNAME/%s\"\n" | xargs -x --no-run-if-empty rm

echo "Performed clean up for dir $SUBDIRNAME with keep count $COUNT_KEEPS."  # >> "/app/direct_echo.log"
