#!/bin/bash

me=${0##*/}
me=${me%.*}
workdir=$(dirname "${dir}")
logfile="${workdir}/log/racecar_${name}_output.log"
user=$(whoami)
consumer_params=${consumer_params:-}

p_err(){
    echo "Fatal: $1"
    exit 1
}

getpid() {
    pid=`ps aux | awk -v pattern="$user.*racecar .*EventsConsumer .*${name}_output.*" '$0 ~ pattern && ! /awk/ && ! /script/ {print $2}'`;
}

check_status() {
    getpid
    if [ x"$pid" != x"" ] ; then
        echo "racecar consumer $name is running, its pid is $pid"
        return 0
    else
        echo "racecar consumer $name is not running"
        return 1
    fi
}

check_disabled() {
    if [ -f "$workdir/tmp/pids/$me.disabled" ] ; then
        return 1
    else
        return 0
    fi
}

check_manual() {
    if [ -f "$workdir/tmp/pids/$me.manual" ] ; then
        return 1
    else
        return 0
    fi
}

logrotate() {
    # Rotate old logs
    for log in $logfile ; do
        for i in 4 3 2 1 0 ; do
            [ -f $log.$i ] && mv -f $log.$i $log.`expr $i + 1`
        done

        # Rotate current log
        [ -f $log ] && mv $log $log.0 && touch $log
    done
}

start() {
    check_disabled || exit 1
    getpid
    [ x"$pid" != x ] && exit 0
    pushd $workdir >/dev/null
    bundle exec racecar EventsConsumer $consumer_params --log "$logfile" >> "$logfile" 2>&1 &
    popd >/dev/null
}

stop() {
    try_num=0
    while true ; do
        getpid;
        if [ x"$pid" != x"" ] ; then
            try_num=$(($try_num + 1))
            if [ "$try_num" -lt "10" ] ; then
                kill -TERM $pid
            else
                kill -KILL $pid
            fi
            sleep 2;
        else
            break;
        fi
    done
}

case "$1" in
    start)
        start;
        ;;
    stop)
        stop;
        ;;
    restart)
        stop;
        start;
        ;;
    status)
        check_status
        ;;
    watchdog)
        check_manual || exit 1
        check_disabled || exit 1
        check_status >/dev/null || ( start >/dev/null ; /usr/bin/logger -t racecar RESTARTED ) ;
        ;;
    logrotate)
        logrotate;
        $0 restart >/dev/null;
        ;;
    enable)
        rm -f "$workdir/tmp/pids/$me.disabled"
        $0 start;
        ;;
    disable)
        touch "$workdir/tmp/pids/$me.disabled"
        $0 stop;
        ;;
    auto)
        rm -f "$workdir/tmp/pids/$me.manual"
        ;;
    manual)
        touch "$workdir/tmp/pids/$me.manual"
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|status|watchdog|logrotate|enable|disable|auto|manual}"
        exit 2
esac
