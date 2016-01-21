#!/bin/bash
#
# description: Apache Tomcat init script
# processname: tomcat
# chkconfig: 234 20 80
#

#Location of JAVA_HOME (bin files)
export JAVA_HOME=/usr/java/latest

# Add JAVA_OPTS
export JAVA_OPTS='-server -Xms2048m -Xmx3072m -Duser.language=nl -Duser.region=NL'
export JAVA_OPTS="${JAVA_OPTS} -Dalfresco.home=${ALF_HOME} -Dcom.sun.management.jmxremote"

#Add Java binary files to PATH
export PATH=$JAVA_HOME/bin:$PATH

#CATALINA_HOME is the location of the bin files of Tomcat
export CATALINA_HOME=/opt/tomcat

#CATALINA_BASE is the location of the configuration files of this instance of Tomcat
export CATALINA_BASE=/opt/tomcat

#TOMCAT_USER is the default user of tomcat
export TOMCAT_USER=tomcat

#TOMCAT_USAGE is the message if this script is called without any options
TOMCAT_USAGE="Usage: $0 {start | stop | status | restart}"

#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
SHUTDOWN_WAIT=20

tomcat_pid() {
        echo `ps aux | grep org.apache.catalina.startup.Bootstrap | grep -v grep | awk '{ print $2 }'`
        #echo `ps -fe | grep $CATALINA_BASE | grep -v grep | tr -s " "|cut -d" " -f2`
}

start() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
    echo -e "Tomcat is already running (pid: $pid)"
  else
    echo -e "Starting Tomcat"
      if [ `user_exists $TOMCAT_USER` = "1" ]
      then
        if [[ "${USER}" = "${TOMCAT_USER}" ]] ; then
          $CATALINA_HOME/bin/startup.sh
        else
          /bin/su $TOMCAT_USER -c $CATALINA_HOME/bin/startup.sh
        fi
      else
          echo -e "Tomcat user $TOMCAT_USER does not exists."
          exit 1
      fi
    status
  fi
  return 0
}

status(){
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
    then echo -e "Tomcat is running with pid: $pid"
  else
    echo -e "Tomcat is not running"
    return 3
  fi
}

stop() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
    echo -e "Stopping Tomcat"
      if [ `user_exists $TOMCAT_USER` = "1" ]
      then
        if [[ "${USER}" = "${TOMCAT_USER}" ]] ; then
          $CATALINA_HOME/bin/shutdown.sh
        else
          /bin/su $TOMCAT_USER -c $CATALINA_HOME/bin/shutdown.sh
        fi
      else
          echo -e "Tomcat user $TOMCAT_USER does not exists."
          exit 1
      fi

    let kwait=$SHUTDOWN_WAIT
    count=0
    count_by=1
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
      echo "Waiting for processes to exit. Timeout before we kill the pid: ${count}/${kwait}"
      sleep $count_by
      let count=$count+$count_by;
    done

    if [ $count -gt $kwait ]; then
      echo "Killing processes which didn't stop after $SHUTDOWN_WAIT seconds"
      kill -9 $pid
      status
    fi
  else
    echo -e "Tomcat is not running"
  fi
  return 0
}

user_exists(){
        if id -u $1 >/dev/null 2>&1; then
          echo "1"
        else
          echo "0"
        fi
}

case $1 in
    start)
      start
    ;;
    stop)
      stop
    ;;
    restart)
      stop
      start
    ;;
    status)
        status
        exit $?
    ;;
    *)
        echo -e $TOMCAT_USAGE
    ;;
esac
exit 0
