#! /bin/bash

export DA_ROOT="${DA_ROOT:-/usr/share/docassemble}"
export DA_ACTIVATE="${DA_PYTHON:-${DA_ROOT}/local}/bin/activate"
export DA_CONFIG_FILE="${DA_CONFIG:-${DA_ROOT}/config/config.yml}"
export CONTAINERROLE=":${CONTAINERROLE:-all}:"
source /dev/stdin < <(su -c "source $DA_ACTIVATE && python -m docassemble.base.read_config $DA_CONFIG_FILE" www-data)

set -- $LOCALE
export LANG=$1

for old_dir in $( find /tmp -maxdepth 1 -type d -mmin +60 -path "/tmp/SavedFile*" ); do
    rm -rf "$old_dir"
done	       

for old_file in $( find /tmp -maxdepth 1 -type f -mmin +60 -path "/tmp/datemp*" ); do
    rm -f "$old_file"
done

if [ -d /tmp/files ]; then
    for old_file in $( find /tmp/files -type f -amin +120 ); do
	rm -f "$old_file"
    done
    for old_file in $( find /tmp/files -type l -amin +120 ); do
	rm -f "$old_file"
    done
    find /tmp/files -type d -empty -delete
fi

if [[ $CONTAINERROLE =~ .*:(all|cron):.* ]]; then
    ${DA_ROOT}/webapp/run-cron.sh cron_hourly
    su -c "source $DA_ACTIVATE && python -m docassemble.webapp.cleanup_sessions $DA_CONFIG_FILE" www-data
fi

